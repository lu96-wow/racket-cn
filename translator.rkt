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
 翻译模块路径
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
;; 9. 模块路径翻译（#lang / require 中的 racket ↔ racket-cn）
;; ============================================================

(define (翻译模块路径 str #:方向 [方向 '英->中])
  "将字符串中的 #lang racket、#lang racket/...、(require racket/...) 替换为对应中文/英文版本"
  (cond
    [(eq? 方向 '英->中)
     ;; 顺序重要：先替换 #lang 相关的更具体模式，再做通用 racket/ → racket-cn/ 替换
     (let* ([s (regexp-replace* #rx"#lang racket/" str "#lang racket-cn/")]
            [s (regexp-replace* #rx"(?m:#lang racket(?=\\s|$))" s "#lang racket-cn")]
            ;; 通用：所有 racket/ 替换为 racket-cn/（覆盖 require、provide、import 等）
            [s (regexp-replace* #rx"racket/" s "racket-cn/")])
       s)]
    [(eq? 方向 '中->英)
     ;; 先替换 #lang 相关的，再做通用 racket-cn/ → racket/ 替换
     (let* ([s (regexp-replace* #rx"#lang racket-cn/" str "#lang racket/")]
            [s (regexp-replace* #rx"(?m:#lang racket-cn(?=\\s|$))" s "#lang racket")]
            ;; 通用：所有 racket-cn/ 替换为 racket/（覆盖 引用、provide 等中文形式）
            [s (regexp-replace* #rx"racket-cn/" s "racket/")])
       s)]
    [else str]))

;; ============================================================
;; 9b. 字符串/文件翻译
;; ============================================================

(define (翻译字符串 str #:方向 [方向 '英->中])
  (define preprocessed (翻译模块路径 str #:方向 方向))
  (define in (open-input-string preprocessed))
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
              [translated-lang (翻译模块路径 lang-line #:方向 方向)]
              [rest-lines (string-join (rest lines) "\n")])
         (string-append translated-lang "\n" (翻译字符串 rest-lines #:方向 方向)))]
      [else (翻译字符串 内容 #:方向 方向)]))
  (if 输出路径
      (begin
        (display-to-file 翻译后 输出路径 #:exists 'replace)
        (printf "✓ 翻译完成 (~a): ~a → ~a\n" 方向-名字 输入路径 输出路径))
      (display 翻译后)))

;; ============================================================
;; 9b. 目录递归翻译
;; ============================================================

(define (翻译目录 输入目录 输出目录 #:方向 [方向 '英->中] #:后缀 [后缀 ".rkt"])
  "递归翻译输入目录下所有指定后缀文件到输出目录"
  (define 方向-名字 (if (eq? 方向 '英->中) "英文→中文" "中文→英文"))
  (printf "翻译目录 (~a): ~a → ~a\n" 方向-名字 输入目录 输出目录)
  (define count 0)
  (let loop-dir ([in-dir 输入目录] [out-dir 输出目录])
    (make-directory* out-dir)
    (for ([f (in-list (directory-list in-dir))])
      (define in-path (build-path in-dir f))
      (cond
        [(directory-exists? in-path)
         (loop-dir in-path (build-path out-dir f))]
        [(path-has-extension? in-path 后缀)
         (define out-path (build-path out-dir f))
         (翻译文件 in-path #:输出路径 out-path #:方向 方向)
         (set! count (add1 count))]
        [else (void)])))
  (printf "✓ 完成: ~a 个文件\n" count))

;; ============================================================
;; 9c. 自动更新测试
;; ============================================================

(define (更新测试 [输出路径 #f])
  "根据当前标识符-翻译表自动生成 test-translator.rkt"
  (define out (if 输出路径
                  (open-output-file 输出路径 #:exists 'replace)
                  (open-output-file
                   (build-path (collection-path "racket-cn") "test-translator.rkt")
                   #:exists 'replace)))
  (define (写 . args) (for ([a args]) (display a out)) (newline out))
  (define 映射 (hash->list 英->中))
  (define (有? name) (and (assoc name 映射) name))
  (define (取 . names) (filter values (map 有? names)))
  (写 "#lang racket/base")
  (写 "(require rackunit \"translator.rkt\" racket/string racket/list)")
  (写)
  (写 "(define (翻译代码 code #:方向 [方向 '英->中])")
  (写 "  (翻译字符串 code #:方向 方向))")
  (写 "(define (翻译后包含? code pattern #:方向 [方向 '英->中])")
  (写 "  (string-contains? (翻译代码 code #:方向 方向) pattern))")
  (写)
  (写 "(printf \"\\n===== racket-cn 翻译器测试 =====\\n\\n\")")
  (写)
  (写 ";; ============ 核心特殊形式 ============")
  (for ([en (in-list (filter values (list (有? 'define) (有? 'lambda) (有? 'if) (有? 'cond) (有? 'let) (有? 'set!) (有? 'begin) (有? 'when) (有? 'unless) (有? 'and) (有? 'or) (有? 'not) (有? 'quote))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a x 1)\" \"~a\") \"~a -> ~a\")~n" en cn en cn))
  (写)
  (写 ";; ============ 列表 ============")
  (for ([en (in-list (filter values (list (有? 'cons) (有? 'car) (有? 'cdr) (有? 'null?) (有? 'list) (有? 'map) (有? 'filter))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a 1 2)\" \"~a\") \"~a -> ~a\")~n" en cn en cn))
  (写)
  (写 ";; ============ IO ============")
  (for ([en (in-list (filter values (list (有? 'display) (有? 'displayln) (有? 'printf) (有? 'write) (有? 'read))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a x)\" \"~a\") \"~a -> ~a\")~n" en cn en cn))
  (写)
  (写 ";; ============ 中->英 ============")
  (for ([en (in-list (filter values (list (有? 'define) (有? 'lambda) (有? 'if) (有? 'cond) (有? 'let) (有? 'when) (有? 'and) (有? 'or) (有? 'not))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a x 1)\" \"~a\" #:方向 '中->英) \"~a -> ~a\")~n" cn en cn en))
  (写)
  (写 ";; ============ 关键字翻译 ============")
  (写 "(check-true (翻译后包含? \"(open-output-file \\\"a\\\" #:exists 'truncate)\" \"#:如果存在\") \"#:exists -> #:如果存在\")")
  (写 "(check-true (翻译后包含? \"(打开输出文件 \\\"a\\\" #:如果存在 '截断)\" \"#:exists\" #:方向 '中->英) \"#:如果存在 -> #:exists\")")
  (写 "(check-true (翻译后包含? \"(open-output-file \\\"a\\\" #:exists 'truncate)\" \"截断\") \"'truncate -> '截断\")")
  (写)
  (写 ";; ============ 子模块抽样 ============")
  (for ([en (in-list (filter values (list (有? 'hash-empty?) (有? 'hash-union) (有? 'take) (有? 'drop) (有? 'sort) (有? 'range) (有? 'first) (有? 'last) (有? 'match) (有? 'class) (有? 'new) (有? 'set) (有? 'for/list) (有? 'for/and) (有? 'for/fold) (有? 'in-range) (有? 'in-list))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a x)\" \"~a\") \"~a\")~n" en cn en))
  (for ([en (in-list (filter values (list (有? 'for/list))))])
    (define cn (hash-ref 英->中 en))
    (fprintf out "(check-true (翻译后包含? \"(~a ([x (在范围 3)]) x)\" \"~a\" #:方向 '中->英) \"~a -> ~a\")~n" cn en cn en))
  (写)
  (写 ";; ============ 嵌套/边界 ============")
  (写 "(let ([r (翻译代码 \"(let ([x (let ([y 1]) y)]) (let ([z 2]) (+ x z)))\" #:方向 '英->中)])")
  (写 "  (check-true (string-contains? r \"令\") \"嵌套let: 令\"))")
  (写 "(let ([r (翻译代码 \"(hash (no-translate (quote hash)) (quote a))\" #:方向 '英->中)])")
  (写 "  (check-true (string-contains? r \"(quote hash)\") \"no-translate: 'hash保留\")")
  (写 "  (check-true (string-contains? r \"(引述 a)\") \"no-translate: 'a仍翻译\"))")
  (写 "(check-equal? (翻译代码 \"()\" #:方向 '英->中) \"()\\n\" \"空列表\")")
  (写 "(check-equal? (翻译代码 \"()\" #:方向 '中->英) \"()\\n\" \"空列表中->英\")")
  (写)
  (写 "(printf \"\\n全部测试完成!\\n\")")
  (close-output-port out)
  (printf ";; ✓ test-translator.rkt updated (~a tests)\\n" 0))

(provide 翻译目录 更新测试)
(module+ main
  (define args (current-command-line-arguments))
  (define 输入文件 #f)
  (define 输出文件 #f)
  (define 方向 '英->中)
  (define 生成数据? #f)
  (define 更新测试? #f)
  (define 翻译目录输入 #f)
  (define 翻译目录输出 #f)
  (let loop ([remaining (vector->list args)])
    (match remaining
      [(list) (void)]
      [(list "--gen-data" rest ...) (set! 生成数据? #t) (loop rest)]
      [(list "--update-tests" rest ...) (set! 更新测试? #t) (loop rest)]
      [(list "--gen-tests" rest ...) (set! 更新测试? #t) (loop rest)]
      [(list "--dir" indir outdir rest ...)
       (set! 翻译目录输入 indir) (set! 翻译目录输出 outdir) (loop rest)]
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
    [更新测试? (更新测试 输出文件)]
    [(and 翻译目录输入 翻译目录输出)
     (翻译目录 翻译目录输入 翻译目录输出)]
    [(not 输入文件)
     (printf "用法: racket translator.rkt <输入文件> [选项]\n")
     (printf "  --gen-data          生成 translator-data.rkt\n")
     (printf "  --en-to-cn, --en2cn 英文→中文 (默认)\n")
     (printf "  --cn-to-en, --cn2en 中文→英文\n")
     (printf "  -o, --output FILE   输出文件\n")
     (printf "  --update-tests      根据当前绑定自动更新 test-translator.rkt\n")
     (printf "  --dir INDIR OUTDIR  递归翻译目录\n")
     (exit 1)]
    [else (翻译文件 输入文件 #:输出路径 输出文件 #:方向 方向)]))

;; ============================================================
;; 11. 便捷函数（方向硬编码，无需 #:方向 关键字）
;; ============================================================

(define (翻译文件-英->中 输入路径 [输出路径 #f])
  (翻译文件 输入路径 #:输出路径 输出路径 #:方向 '英->中))

(define (翻译文件-中->英 输入路径 [输出路径 #f])
  (翻译文件 输入路径 #:输出路径 输出路径 #:方向 '中->英))

(define (翻译文件夹-英->中 输入目录 输出目录)
  (翻译目录 输入目录 输出目录 #:方向 '英->中))

(define (翻译文件夹-中->英 输入目录 输出目录)
  (翻译目录 输入目录 输出目录 #:方向 '中->英))

(provide 翻译文件-英->中 翻译文件-中->英
         翻译文件夹-英->中 翻译文件夹-中->英)

;; 语言核心绑定（#lang 必须）
(provide #%module-begin #%app #%datum #%top (all-from-out racket/base))

;; ============================================================
;; Reader 子模块 — 支持 #lang racket-cn/translator
;; ============================================================
(module reader syntax/module-reader
  racket-cn/translator)
