#lang racket/base

;; ============================================================
;; collect-mappings.rkt — 遍历所有源文件，收集 eng→中文 映射表
;;
;; 覆盖以下翻译方式：
;;   方式1:  (rename-define [eng cn ...] ...)
;;   方式1b: (rename-define/for-syntax [eng cn ...] ...)
;;   方式2:  (define-syntax cn (make-rename-transformer #'eng))
;;   方式3:  (定义-关键字函数 cn eng (#:cnkw #:enkw (cnv env)...)...)
;;
;; 用法：
;;   racket collect-mappings.rkt
;; ============================================================

(require racket/list
         racket/string
         racket/file
         racket/path
         racket/match)

;; ── 文件发现 ────────────────────────────────────────────────

(define (find-rkt-files dir)
  (let loop ([items (directory-list dir #:build? #f)])
    (append*
     (for/list ([f (in-list items)])
       (let ([full (build-path dir f)])
         (cond
           [(and (directory-exists? full)
                 (not (member f '("compiled" "doc"))))
            (loop (for/list ([x (directory-list full)])
                    (build-path f x)))]
           [(and (file-exists? full) (regexp-match? #rx"[.]rkt$" f))
            (list full)]
           [else '()]))))))

;; ── 读取 s-expression ───────────────────────────────────────

(define (read-file-exprs file)
  ;; 跳过 #lang 行，然后读取所有 s-expression
  (call-with-input-file file
    (lambda (port)
      ;; 读取并丢弃 #lang 行
      (let ([first (read-line port)])
        (if (and (string? first)
                 (string-prefix? first "#lang"))
            (void)
            (void)))
      ;; 读取剩余内容
      (let loop ([acc '()])
        (let ([v (read port)])
          (if (eof-object? v)
              (reverse acc)
              (loop (cons v acc))))))))

;; ── 映射记录 ────────────────────────────────────────────────

(struct mapping
  (english chinese type source)
  #:transparent)

(define (mapping* eng cn type file)
  (mapping eng cn type (if (path? file) (path->string file) file)))

;; ── 方式1/1b: rename-define / rename-define/for-syntax ────

(define (collect-from-rename-define expr file)
  (match expr
    [`(,(or 'rename-define 'rename-define/for-syntax)
       ,clauses ...)
     (let ([type (if (eq? (car expr) 'rename-define/for-syntax)
                     'rename-define/for-syntax
                     'rename-define)])
       (append*
        (for/list ([clause (in-list clauses)])
          (match clause
            [`[,eng ,cns ...]
             (for/list ([cn (in-list cns)])
               (mapping* eng cn type file))]
            [_ '()]))))]
    [_ '()]))

;; ── 方式2: define-syntax + make-rename-transformer ─────────

(define (collect-from-define-syntax expr file)
  (match expr
    [`(define-syntax ,cn
        (make-rename-transformer (syntax ,eng)))
     (list (mapping eng cn 'define-syntax file))]
    [_ '()]))

;; ── 方式3: 定义-关键字函数 ─────────────────────────────────

(define (collect-from-define-kw expr file)
  (match expr
    [`(定义-关键字函数 ,cn ,eng ,kw-clauses ...)
     (define fn-map
       (list (mapping eng cn '关键字函数 file)))
     (define kw-maps
       (append*
        (for/list ([clause (in-list kw-clauses)])
          (match clause
            [`(,cnkw ,enkw ,pairs ...)
             (cons
              (mapping enkw cnkw '关键字 file)
              (for/list ([pair (in-list pairs)])
                (match pair
                  [`(,cnv ,env)
                   (mapping env cnv '关键字值 file)]
                  [_ #f])))]
            [_ '()]))))
     (append fn-map (filter values kw-maps))]
    [_ '()]))

;; ── S-expression 递归遍历 ──────────────────────────────────

(define (walk-exprs exprs file)
  (append*
   (for/list ([expr (in-list exprs)])
     (if (pair? expr)
         (walk-one expr file)
         '()))))

(define (walk-one expr file)
  (if (pair? expr)
      (let ([head (car expr)])
        (cond
          [(eq? head 'rename-define)
           (collect-from-rename-define expr file)]
          [(eq? head 'rename-define/for-syntax)
           (collect-from-rename-define expr file)]
          [(eq? head 'define-syntax)
           (collect-from-define-syntax expr file)]
          [(eq? head '定义-关键字函数)
           (collect-from-define-kw expr file)]
          [else '()]))
      '()))

;; ── 主收集逻辑 ─────────────────────────────────────────────

(define (collect-all-mappings root-dir)
  (define files (find-rkt-files root-dir))
  (printf "扫描 ~a 个 .rkt 文件...\n" (length files))
  (append*
   (for/list ([file (in-list files)])
     (with-handlers ([exn:fail:read?
                      (lambda (e)
                        (printf "  警告: 无法读取 ~a: ~a\n"
                                file (exn-message e))
                        '())])
       (let ([exprs (read-file-exprs file)])
         (walk-exprs exprs file))))))

;; ── 输出 ───────────────────────────────────────────────────

(define (print-mappings mappings)
  (define (by-type type)
    (filter (lambda (m) (eq? (mapping-type m) type)) mappings))

  (define (print-group title ms)
    (unless (null? ms)
      (printf "\n## ~a (~a 条)\n" title (length ms))
      (printf "| 英文 | 中文 | 类型 | 来源 |\n")
      (printf "|------|------|------|------|\n")
      (for ([m (in-list ms)])
        (printf "| ~a | ~a | ~a | ~a |\n"
                (mapping-english m) (mapping-chinese m)
                (mapping-type m)
                (let ([p (mapping-source m)])
                  (if (string? p)
                      (path->string
                       (find-relative-path (current-directory) p))
                      p))))))

  (print-group "方式1: rename-define" (by-type 'rename-define))
  (print-group "方式1b: rename-define/for-syntax"
               (by-type 'rename-define/for-syntax))
  (print-group "方式2: define-syntax" (by-type 'define-syntax))
  (print-group "方式3: 关键字函数名" (by-type '关键字函数))
  (print-group "方式3: 关键字名" (by-type '关键字))
  (print-group "方式3: 关键字值" (by-type '关键字值))

  (printf "\n## 总计: ~a 条映射 (~a 唯一英文, ~a 唯一中文)\n"
          (length mappings)
          (length (remove-duplicates (map mapping-english mappings)))
          (length (remove-duplicates (map mapping-chinese mappings))))

  (define out-file "mappings-table.rktd")
  (call-with-output-file out-file
    (lambda (port)
      (write
       (for/list ([m (in-list mappings)])
         (list (mapping-english m) (mapping-chinese m)
               (mapping-type m) (mapping-source m)))
       port)
      (newline port)))
  (printf "\n映射表已保存到 ~a\n" out-file))

;; ── 入口 ───────────────────────────────────────────────────

(module+ main
  (define root (current-directory))
  (printf "正在从 ~a 收集映射...\n" root)
  (define all-maps (collect-all-mappings root))
  (printf "\n收集完成！\n")
  (print-mappings all-maps))
