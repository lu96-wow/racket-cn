#lang racket/base

(require racket/list
         racket/string
         racket/file
         racket/path
         racket/match
         racket/runtime-path)

(provide update-mapping-table!
         (struct-out mapping))

;; ── 映射结构 ────────────────────────────────────────────

(struct mapping (english chinese type source) #:transparent)

(define (mapping* eng cn type file)
  (mapping eng cn type (if (path? file) (path->string file) file)))

;; ── 文件发现 ────────────────────────────────────────────

(define-runtime-path default-project-root "../..")
(define-runtime-path mapping-table-path "../mappings-table.rktd")

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

(define (read-file-exprs file)
  (call-with-input-file file
    (lambda (port)
      (let ([first (read-line port)])
        (void))
      (let loop ([acc '()])
        (let ([v (read port)])
          (if (eof-object? v) (reverse acc) (loop (cons v acc))))))))

;; ── 收集器 ──────────────────────────────────────────────

(define (collect-from-rename-define expr file)
  (match expr
    [`(,(or 'rename-define 'rename-define/for-syntax) ,clauses ...)
     (define type (if (eq? (car expr) 'rename-define/for-syntax)
                      'rename-define/for-syntax 'rename-define))
     (append*
      (for/list ([clause (in-list clauses)])
        (match clause
          [`[,eng ,cns ...]
           (for/list ([cn (in-list cns)]) (mapping* eng cn type file))]
          [_ '()])))]
    [_ '()]))

(define (collect-from-define-syntax expr file)
  (match expr
    [`(define-syntax ,cn (make-rename-transformer (syntax ,eng)))
     (list (mapping* eng cn 'define-syntax file))]
    [_ '()]))

(define (collect-from-define-kw expr file)
  (match expr
    [`(定义-关键字函数 ,cn ,eng ,kw-clauses ...)
     (define fn-map (list (mapping* eng cn '关键字函数 file)))
     (define kw-maps
       (append*
        (for/list ([clause (in-list kw-clauses)])
          (match clause
            [`(,cnkw ,enkw ,pairs ...)
             (cons (mapping* enkw cnkw '关键字 file)
                   (for/list ([pair (in-list pairs)])
                     (match pair
                       [`(,cnv ,env) (mapping* env cnv '关键字值 file)]
                       [_ #f])))]
            [_ '()]))))
     (append fn-map (filter values kw-maps))]
    [_ '()]))

(define (walk-one expr file)
  (and (pair? expr)
       (let ([head (car expr)])
         (cond [(eq? head 'rename-define)          (collect-from-rename-define expr file)]
               [(eq? head 'rename-define/for-syntax) (collect-from-rename-define expr file)]
               [(eq? head 'define-syntax)          (collect-from-define-syntax expr file)]
               [(eq? head '定义-关键字函数)        (collect-from-define-kw expr file)]
               [else #f]))))

(define (walk-exprs exprs file)
  (append*
   (for/list ([expr (in-list exprs)])
     (if (pair? expr)
         (or (walk-one expr file) '())
         '()))))

(define (collect-all-mappings root-dir)
  (define files (find-rkt-files root-dir))
  (append*
   (for/list ([file (in-list files)])
     (with-handlers ([exn:fail:read? (lambda (e) '())])
       (walk-exprs (read-file-exprs file) file)))))

(define (write-mapping-table mappings path)
  (call-with-output-file path #:exists 'replace
    (lambda (port)
      (write
       (for/list ([m (in-list mappings)])
         (list (mapping-english m) (mapping-chinese m)
               (mapping-type m) (mapping-source m)))
       port)
      (newline port))))

;; ── 公开 API ────────────────────────────────────────────

(define (update-mapping-table! [root-dir default-project-root])
  (printf "正在从 ~a 收集映射...\n" root-dir)
  (define all-maps (collect-all-mappings root-dir))
  (write-mapping-table all-maps mapping-table-path)
  (printf "已生成 ~a 条映射 -> ~a\n" (length all-maps) mapping-table-path)
  (length all-maps))

(module+ main
  (update-mapping-table!))
