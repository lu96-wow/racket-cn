#lang racket/base

;; ============================================================
;; racket-cn/translator — 中文 Racket ↔ 英文 Racket 翻译器
;;
;; 设计：用 read 读取源文件（支持 #lang），转为 syntax 对象后
;; 用 syntax-parse 精确匹配 rename-out/定义-关键字函数 等。
;; module.rkt 的 define-syntax + make-rename-transformer 单独处理。
;; 提供 生成-翻译数据 函数生成 translator-data.rkt，避免手写转换值。
;; ============================================================

(require (for-syntax racket/base syntax/parse)
         syntax/parse
         racket/dict
         racket/file
         racket/list
         racket/match
         racket/path
         racket/string)

(provide
 翻译文件
 翻译语法
 翻译字符串
 英->中
 中->英
 标识符-翻译表
 生成-翻译数据)

;; ============================================================
;; 1. 源文件读取：strip #lang 后用 read，再转 syntax
;; ============================================================

(define (读源文件为语法 filepath)
  (define content (file->string filepath))
  (define cleaned
    (if (string-prefix? content "#lang")
        (let ([lines (string-split content "\n")])
          (string-join (rest lines) "\n"))
        content))
  (define in (open-input-string cleaned))
  (begin0
    (let loop ([acc '()])
      (define val (read in))
      (if (eof-object? val)
          (reverse acc)
          (loop (cons (datum->syntax #f val) acc))))
    (close-input-port in)))

;; ============================================================
;; 2. rename-out 提取器（syntax-parse）
;; ============================================================

(define (提取-rename-out clause-stx)
  (syntax-parse clause-stx
    [(rename-out [eng:identifier cn:identifier] ...)
     (for/list ([e (syntax->list #'(eng ...))]
                [c (syntax->list #'(cn ...))])
       (cons (syntax-e e) (syntax-e c)))]
    [(~or (for-syntax sub)
          (for-label sub)
          (for-meta _ sub)
          (for-template sub))
     (提取-rename-out #'sub)]
    [_ '()]))

;; ============================================================
;; 3. 顶层 form 提取：provide+rename-out 和 定义-关键字函数
;; ============================================================

(define (提取-标识符-映射 stx)
  (syntax-parse stx
    [(provide clause ...)
     (append* (for/list ([c (syntax->list #'(clause ...))])
                (提取-rename-out c)))]
    [_ '()]))

(define (提取-关键字-映射 stx)
  (define kw-map '())
  (define val-map '())
  (syntax-parse stx
    [(定义-关键字函数 _:identifier _:identifier kw-clause ...)
     (for ([clause (syntax->list #'(kw-clause ...))])
       (syntax-parse clause
         [(cn-kw:keyword en-kw:keyword (cn-v:identifier en-v:identifier) ...)
          (set! kw-map (cons (cons (syntax-e #'en-kw)
                                   (syntax-e #'cn-kw)) kw-map))
          (define vps
            (for/list ([cv (syntax->list #'(cn-v ...))]
                       [ev (syntax->list #'(en-v ...))])
              (cons (syntax-e cv) (syntax-e ev))))
          (set! val-map (cons (cons (syntax-e #'en-kw) vps) val-map))]
         [_ (void)]))]
    [_ (void)])
  (values (reverse kw-map) (reverse val-map)))

;; ============================================================
;; 4. module.rkt 特殊处理：define-syntax + make-rename-transformer
;;    read 把 #'en 读为 (syntax en)，用 match 在 datum 上匹配
;; ============================================================

(define (提取-module-映射 stx)
  (match (syntax->datum stx)
    [`(define-syntax ,cn (make-rename-transformer (syntax ,en)))
     (list (cons en cn))]
    [_ '()]))

;; ============================================================
;; 5. 文件级扫描
;; ============================================================

(define (扫描文件-标识符 filepath)
  (with-handlers ([exn:fail:filesystem?
                   (λ (e) (printf "⚠ skip ~a: ~a\n"
                            (file-name-from-path filepath)
                            (exn-message e))
                      '())])
    (define stxs (读源文件为语法 filepath))
    (append* (for/list ([stx (in-list stxs)])
               (if (string-suffix? (path->string filepath) "module.rkt")
                   (提取-module-映射 stx)
                   (提取-标识符-映射 stx))))))

(define (扫描文件-关键字 filepath)
  (with-handlers ([exn:fail:filesystem?
                   (λ (e) (values '() '()))])
    (define stxs (读源文件为语法 filepath))
    (define kw-map '())
    (define val-map '())
    (for ([stx (in-list stxs)])
      (define-values (kw vm) (提取-关键字-映射 stx))
      (set! kw-map (append kw-map kw))
      (set! val-map (append val-map vm)))
    (values kw-map val-map)))

(define (扫描-所有-文件)
  (define racket-dir (build-path (collection-path "racket-cn") "racket"))
  (define sub-files
    (for/list ([f (in-list (directory-list racket-dir #:build? #t))]
               #:when (and (path-has-extension? f #".rkt")
                           (file-exists? f)
                           (not (member (path->string (file-name-from-path f))
                                        '("base-impl.rkt" "main.rkt"
                                          "info.rkt")))))
      f))
  (define ffi-dir (build-path (collection-path "racket-cn") "ffi"))
  (define ffi-top
    (for/list ([f (in-list (directory-list ffi-dir #:build? #t))]
               #:when (and (path-has-extension? f #".rkt")
                           (file-exists? f)
                           (not (member (path->string (file-name-from-path f))
                                        '("main.rkt" "info.rkt")))))
      f))
  (define ffi-unsafe-dir (build-path ffi-dir "unsafe"))
  (define ffi-unsafe
    (if (directory-exists? ffi-unsafe-dir)
        (for/list ([f (in-list (directory-list ffi-unsafe-dir #:build? #t))]
                   #:when (and (path-has-extension? f #".rkt")
                               (file-exists? f)))
          f)
        '()))
  (append
   (list (build-path racket-dir "base-impl.rkt"))
   sub-files
   (list (build-path (collection-path "racket-cn") "json" "main.rkt"))
   (list (build-path (collection-path "racket-cn") "main.rkt"))
   (list (build-path (collection-path "racket-cn") "module.rkt"))
   ffi-top
   ffi-unsafe))

(define (收集-所有-翻译映射)
  (define id-maps '())
  (define kw-maps '())
  (define kw-val-maps '())
  (for ([f (in-list (扫描-所有-文件))]
        #:when (file-exists? f))
    (printf ";; scan: ~a\n" (file-name-from-path f))
    (set! id-maps (append id-maps (扫描文件-标识符 f)))
    (define-values (kw vm) (扫描文件-关键字 f))
    (set! kw-maps (append kw-maps kw))
    (set! kw-val-maps (append kw-val-maps vm)))
  ;; 去重：保留首次出现的 eng→cn 映射
  (define (去重 pairs)
    (reverse (let loop ([pairs (reverse pairs)] [seen '()] [acc '()])
               (cond [(null? pairs) acc]
                     [(member (caar pairs) seen)
                      (loop (cdr pairs) seen acc)]
                     [else (loop (cdr pairs)
                                 (cons (caar pairs) seen)
                                 (cons (car pairs) acc))]))))
  (values (去重 id-maps) (去重 kw-maps) (去重 kw-val-maps)))

;; 模块加载时扫描
(define-values (标识符-翻译表 关键字-翻译表 关键字值-翻译表)
  (收集-所有-翻译映射))

;; ============================================================
;; 6. 生成 translator-data.rkt
;; ============================================================

(define (生成-翻译数据 [输出路径 #f])
  (define-values (id-map kw-map kw-val-map) (收集-所有-翻译映射))
  (define out (if 输出路径
                  (open-output-file 输出路径 #:exists 'replace)
                  (open-output-file
                   (build-path (collection-path "racket-cn") "translator-data.rkt")
                   #:exists 'replace)))
  (displayln "#lang racket/base" out)
  (displayln ";; translator-data.rkt — auto-generated, do not edit" out)
  (displayln ";; Generated by (生成-翻译数据)" out)
  (displayln "" out)
  (displayln "(provide 标识符-翻译表 关键字-翻译表 关键字值-翻译表)" out)
  (displayln "" out)
  (printf ";; ~a identifier mappings\n" (length id-map))
  (fprintf out "(define 标识符-翻译表~n  '(~n")
  (for ([p (in-list id-map)])
    (fprintf out "    (~s . ~s)~n" (car p) (cdr p)))
  (fprintf out "   ))~n~n")
  (printf ";; ~a keyword mappings\n" (length kw-map))
  (fprintf out "(define 关键字-翻译表~n  '(~n")
  (for ([p (in-list kw-map)])
    (fprintf out "    (~s . ~s)~n" (car p) (cdr p)))
  (fprintf out "   ))~n~n")
  (printf ";; ~a keyword-value mappings\n" (length kw-val-map))
  (fprintf out "(define 关键字值-翻译表~n  '(~n")
  (for ([p (in-list kw-val-map)])
    (fprintf out "    (~s" (car p))
    (for ([vp (in-list (cdr p))])
      (fprintf out " (~s . ~s)" (car vp) (cdr vp)))
    (fprintf out ")~n"))
  (fprintf out "   ))~n")
  (close-output-port out)
  (printf ";; done: ~a id, ~a kw, ~a kw-val\n"
          (length id-map) (length kw-map) (length kw-val-map)))

;; ============================================================
;; 7. 构建双向 Hash 表
;; ============================================================

(define 英->中 (make-hash 标识符-翻译表))
(define 中->英
  (let ([h (make-hash)])
    (for ([p (in-list 标识符-翻译表)])
      (hash-set! h (cdr p) (car p)))
    h))

(define 英kw->中kw (make-hash 关键字-翻译表))
(define 中kw->英kw
  (let ([h (make-hash)])
    (for ([p (in-list 关键字-翻译表)])
      (hash-set! h (cdr p) (car p)))
    h))

(define 英kw->值map
  (for/hash ([(kw cn-vals) (in-dict 关键字值-翻译表)])
    (values kw (for/hash ([p (in-list cn-vals)])
                 (values (cdr p) (car p))))))

(define 中kw->值map
  (for/hash ([(en-kw cn-vals) (in-dict 关键字值-翻译表)])
    (values (dict-ref 英kw->中kw en-kw)
            (for/hash ([p (in-list cn-vals)])
              (values (car p) (cdr p))))))

;; ============================================================
;; 8. 核心翻译函数
;; ============================================================

(define (翻译语法 stx #:方向 [方向 '英->中])
  (let* ([id-map (if (eq? 方向 '英->中) 英->中 中->英)]
         [kw-map (if (eq? 方向 '英->中) 英kw->中kw 中kw->英kw)]
         [kw-val-map (if (eq? 方向 '英->中) 英kw->值map 中kw->值map)])
    (let 翻译递归 ([stx stx] [last-kw #f])
      (syntax-case stx (no-translate)
        [(no-translate expr)  #'expr]
        [(a . d)
         (let* ([a-is-kw? (keyword? (syntax-e #'a))]
                [next-kw (if a-is-kw? (syntax-e #'a) last-kw)]
                [a-trans (翻译递归 #'a last-kw)]
                [d-trans (翻译递归 #'d next-kw)])
           (datum->syntax stx (cons a-trans d-trans) stx stx))]
        [_
         (let ([val (syntax-e stx)])
           (cond
             [(identifier? stx)
              (let ([found (hash-ref id-map val #f)])
                (if found
                    (datum->syntax stx found stx stx)
                    (if last-kw
                        (let* ([vm (hash-ref kw-val-map last-kw #f)]
                               [vfound (and vm (hash-ref vm val #f))])
                          (if vfound
                              (datum->syntax stx vfound stx stx)
                              stx))
                        stx)))]
             [(keyword? val)
              (let ([found (hash-ref kw-map val #f)])
                (if found
                    (datum->syntax stx found stx stx)
                    stx))]
             [(and last-kw (pair? val)
                   (eq? (car val) 'quote)
                   (pair? (cdr val)) (symbol? (cadr val))
                   (null? (cddr val)))
              (let* ([q (cadr val)]
                     [vm (hash-ref kw-val-map last-kw #f)]
                     [found (and vm (hash-ref vm q #f))])
                (if found
                    (datum->syntax stx (list 'quote found) stx stx)
                    stx))]
             [else stx]))]))))

;; ============================================================
;; 9. 字符串/文件翻译
;; ============================================================

(define (翻译字符串 str #:方向 [方向 '英->中])
  (define in (open-input-string str))
  (define out (open-output-string))
  (let loop ()
    (define stx (read-syntax "translation-input" in))
    (unless (eof-object? stx)
      (define translated (翻译语法 stx #:方向 方向))
      (write (syntax->datum translated) out)
      (newline out)
      (loop)))
  (get-output-string out))

(define (翻译文件 输入路径 #:输出路径 [输出路径 #f] #:方向 [方向 '英->中])
  (define 方向-名字 (if (eq? 方向 '英->中) "英文→中文" "中文→英文"))
  (define 内容 (file->string 输入路径))
  (define 翻译后
    (cond
      [(string-prefix? 内容 "#lang")
       (let* ([lines (string-split 内容 "\n")]
              [lang-line (first lines)]
              [rest-lines (string-join (rest lines) "\n")])
         (string-append lang-line "\n" (翻译字符串 rest-lines #:方向 方向)))]
      [else (翻译字符串 内容 #:方向 方向)]))
  (if 输出路径
      (begin
        (display-to-file 翻译后 输出路径 #:exists 'replace)
        (printf "✓ 翻译完成 (~a): ~a → ~a\n" 方向-名字 输入路径 输出路径))
      (display 翻译后)))

;; ============================================================
;; 10. 命令行接口
;; ============================================================
(module+ main
  (define args (current-command-line-arguments))
  (define 输入文件 #f)
  (define 输出文件 #f)
  (define 方向 '英->中)
  (define 生成数据? #f)
  (let loop ([remaining (vector->list args)])
    (match remaining
      [(list) (void)]
      [(list "--gen-data" rest ...) (set! 生成数据? #t) (loop rest)]
      [(list "--en-to-cn" rest ...) (set! 方向 '英->中) (loop rest)]
      [(list "--en2cn" rest ...) (set! 方向 '英->中) (loop rest)]
      [(list "--cn-to-en" rest ...) (set! 方向 '中->英) (loop rest)]
      [(list "--cn2en" rest ...) (set! 方向 '中->英) (loop rest)]
      [(list "-o" path rest ...) (set! 输出文件 path) (loop rest)]
      [(list "--output" path rest ...) (set! 输出文件 path) (loop rest)]
      [(list f rest ...)
       (if (not (string-prefix? f "-"))
           (begin (set! 输入文件 f) (loop rest))
           (error (format "未知选项: ~a" f)))]))
  (cond
    [生成数据? (生成-翻译数据 输出文件)]
    [(not 输入文件)
     (printf "用法: racket translator.rkt <输入文件> [选项]\n")
     (printf "  --gen-data          生成 translator-data.rkt\n")
     (printf "  --en-to-cn, --en2cn 英文→中文 (默认)\n")
     (printf "  --cn-to-en, --cn2en 中文→英文\n")
     (printf "  -o, --output FILE   输出文件\n")
     (exit 1)]
    [else (翻译文件 输入文件 #:输出路径 输出文件 #:方向 方向)]))
