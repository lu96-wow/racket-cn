#lang racket/base

(require racket/list
         racket/string
         racket/file
         racket/path
         racket/match
         racket/pretty
         racket/runtime-path)

(provide translate-file
         translate-directory
         load-mapping-hashes)

;; ── 加载映射表 ──────────────────────────────────────────

(define-runtime-path mapping-file "../mappings-table.rktd")

(define eng->cn (make-hash))
(define cn->eng (make-hash))
(define eng-kw->cn-kw (make-hash))
(define cn-kw->eng-kw (make-hash))

(define (load-mapping-hashes)
  (hash-clear! eng->cn)  (hash-clear! cn->eng)
  (hash-clear! eng-kw->cn-kw) (hash-clear! cn-kw->eng-kw)
  (define data (call-with-input-file mapping-file read))
  (for ([m (in-list data)])
    (match m
      [(list eng cn (or 'rename-define 'rename-define/for-syntax 'define-syntax '关键字函数) _)
       (hash-set! eng->cn eng cn)
       (hash-set! cn->eng cn eng)]
      [(list eng cn '关键字 _)
       (hash-set! eng-kw->cn-kw eng cn)
       (hash-set! cn-kw->eng-kw cn eng)]
      [_ (void)]))
  (hash-count eng->cn))

(load-mapping-hashes)

;; ── 模块路径转换 ─────────────────────────────────────────

(define racket-submodules
  '("async-channel" "base-impl" "block" "bool" "bytes" "case" "class"
    "cmdline" "contract" "control" "date" "deprecation" "dict" "engine"
    "enter" "exn" "extflonum" "fasl" "file" "fixnum" "flonum" "format"
    "function" "future" "generator" "generic" "hash" "hash-code" "help"
    "include" "interaction-info" "keyword" "keyword-transform"
    "language-info" "lazy-require" "linklet" "list" "local" "logging"
    "match" "math" "mutability" "mutable-treelist" "os" "path"
    "performance-hint" "place" "port" "prefab" "pretty" "provide"
    "provide-syntax" "promise" "random" "repl" "require"
    "require-syntax" "rerequire" "runtime-config" "runtime-path"
    "sequence" "serialize" "serialize-structs" "set" "shared"
    "splicing" "stream" "string" "struct" "struct-info" "stxparam"
    "surrogate" "symbol" "syntax" "syntax-srcloc" "system" "tcp"
    "trace" "trait" "treelist" "udp" "undefined" "unit" "unit-exptime"
    "unreachable" "vector"))

(define (translate-module-path path cn->en?)
  (define s (symbol->string path))
  (cond
    [(string=? s "racket-cn") (if cn->en? 'racket 'racket-cn)]
    [(string=? s "racket")    (if cn->en? 'racket 'racket-cn)]
    [(string=? s "racket-cn/base") (if cn->en? 'racket/base 'racket-cn/base)]
    [(string=? s "racket/base")    (if cn->en? 'racket/base 'racket-cn/base)]
    [(regexp-match #rx"^racket-cn/racket/(.+)$" s)
     => (lambda (m) (if cn->en? (string->symbol (format "racket/~a" (cadr m))) path))]
    [(regexp-match #rx"^racket/(.+)$" s)
     => (lambda (m)
          (define sub (cadr m))
          (if (member sub racket-submodules)
              (if cn->en? path (string->symbol (format "racket-cn/racket/~a" sub)))
              path))]
    [(regexp-match #rx"^racket-cn/json$" s) (if cn->en? 'json path)]
    [(regexp-match #rx"^racket-cn/ffi/(.+)$" s)
     => (lambda (m) (if cn->en? (string->symbol (format "ffi/~a" (cadr m))) path))]
    [(string=? s "json") (if cn->en? path 'racket-cn/json)]
    [(regexp-match #rx"^ffi/(.+)$" s)
     => (lambda (m) (if cn->en? path (string->symbol (format "racket-cn/ffi/~a" (cadr m)))))]
    [else path]))

;; ── 核心翻译递归 ─────────────────────────────────────────

(define (translate-expr expr cn->en?)
  (cond
    [(symbol? expr)
     (if cn->en? (hash-ref cn->eng expr expr) (hash-ref eng->cn expr expr))]
    [(keyword? expr)
     (if cn->en? (hash-ref cn-kw->eng-kw expr expr) (hash-ref eng-kw->cn-kw expr expr))]
    [(pair? expr)
     (if (eq? (car expr) 'require)
         (translate-require expr cn->en?)
         (cons (translate-expr (car expr) cn->en?)
               (translate-expr/cdr (cdr expr) cn->en?)))]
    [else expr]))

(define (translate-expr/cdr rest cn->en?)
  (cond [(pair? rest) (cons (translate-expr (car rest) cn->en?)
                            (translate-expr/cdr (cdr rest) cn->en?))]
        [(null? rest) '()]
        [else (translate-expr rest cn->en?)]))

(define (translate-require expr cn->en?)
  (define (walk-spec spec)
    (match spec
      [(list 'for-syntax inner)  (list 'for-syntax (walk-spec inner))]
      [(list 'for-label inner)   (list 'for-label (walk-spec inner))]
      [(list 'for-meta n inner)  (list 'for-meta n (walk-spec inner))]
      [(list 'for-template inner) (list 'for-template (walk-spec inner))]
      [(list 'only-in path ids ...)   (list* 'only-in (translate-path path cn->en?) ids)]
      [(list 'except-in path ids ...) (list* 'except-in (translate-path path cn->en?) ids)]
      [(list 'prefix-in pfx path)     (list 'prefix-in pfx (translate-path path cn->en?))]
      [(list 'rename-in path rns ...) (list* 'rename-in (translate-path path cn->en?) rns)]
      [(? symbol?) (translate-path spec cn->en?)]
      [(? string?) spec]
      [_ spec]))
  (cons 'require (for/list ([s (in-list (cdr expr))]) (walk-spec s))))

(define (translate-path path cn->en?)
  (if (symbol? path) (translate-module-path path cn->en?) path))

;; ── #lang 行翻译 ────────────────────────────────────────

(define (translate-lang-line line cn->en?)
  (cond [(regexp-match #rx"^#lang +racket-cn/base" line)
         (if cn->en? "#lang racket/base" "#lang racket-cn/base")]
        [(regexp-match #rx"^#lang +racket/base" line)
         (if cn->en? "#lang racket/base" "#lang racket-cn/base")]
        [(regexp-match #rx"^#lang +racket-cn" line)
         (if cn->en? "#lang racket" "#lang racket-cn")]
        [(regexp-match #rx"^#lang +racket" line)
         (if cn->en? "#lang racket" "#lang racket-cn")]
        [else line]))

;; ── 覆盖确认 ─────────────────────────────────────────────

(define (confirm-overwrite path)
  "提示用户确认是否覆盖已存在的文件。
   返回: 'overwrite (覆盖此文件) | 'skip (跳过) | 'all (全部覆盖) | 'quit (退出)"
  (if (not (file-exists? path))
      'overwrite
      (let loop ()
        (printf "  文件 ~a 已存在。覆盖? [y]es/[n]o/[a]ll/[q]uit: " path)
        (flush-output)
        (match (string-downcase (read-line))
          [(or "y" "yes") 'overwrite]
          [(or "n" "no")  'skip]
          [(or "a" "all") 'all]
          [(or "q" "quit") 'quit]
          [_ (printf "  请输入 y/n/a/q\n") (loop)]))))

;; ── 文件翻译 ─────────────────────────────────────────────

(define (translate-file in-file out-file #:direction dir
                        #:confirm [confirm-box (box #t)])
  (define cn->en? (eq? dir 'cn->en))
  
  ;; 覆盖确认
  (define action
    (cond [(not confirm-box) 'overwrite]          ;; 已选 all，不确认
          [(not (unbox confirm-box)) 'overwrite]   ;; 已选 all，不确认
          [else (confirm-overwrite out-file)]))    ;; 交互确认
  
  (case action
    [(skip) (printf "  跳过 ~a\n" out-file)]
    [(quit) (printf "  已取消\n") (exit 1)]
    [(all)  (set-box! confirm-box #f)]
    [(overwrite) (void)])
  
  ;; 仅在 overwrite/all 时执行翻译
  (when (member action '(overwrite all))
    (define lines (file->lines in-file))
    (define new-first-line (translate-lang-line (first lines) cn->en?))
    
    (define exprs
      (let ([port (open-input-string
                   (string-join (cons new-first-line (rest lines)) "\n"))])
        (read-line port)
        (let loop ([acc '()])
          (let ([v (read port)])
            (if (eof-object? v)
                (begin (close-input-port port) (reverse acc))
                (loop (cons v acc)))))))
    
    (define translated (for/list ([e (in-list exprs)]) (translate-expr e cn->en?)))
    
    (call-with-output-file out-file #:exists 'replace
      (lambda (port)
        (fprintf port "~a\n" new-first-line)
        (for ([e (in-list translated)]) (pretty-write e port) (newline port))))))

;; ── 目录翻译 ─────────────────────────────────────────────

(define (translate-directory in-dir out-dir #:direction dir
                             #:confirm? [confirm? #t])
  (define cn->en? (eq? dir 'cn->en))
  (define prefix-len (string-length (path->string (simplify-path in-dir))))
  (make-directory* out-dir)
  
  ;; 先收集所有待翻译文件
  (define files-to-translate '())
  (define (collect current-in)
    (for ([f (in-list (directory-list current-in))])
      (define full-in (build-path current-in f))
      (cond
        [(directory-exists? full-in)
         (unless (member f '("compiled" "doc"))
           (collect full-in))]
        [(and (file-exists? full-in) (regexp-match? #rx"[.]rkt$" f))
         (define raw-rel (substring (path->string full-in) prefix-len))
         (define rel (if (and (positive? (string-length raw-rel))
                              (char=? (string-ref raw-rel 0) #\/))
                         (substring raw-rel 1)
                         raw-rel))
         (define full-out (build-path out-dir rel))
         (set! files-to-translate (cons (list full-in full-out rel) files-to-translate))])))
  
  (printf "翻译目录: ~a -> ~a (~a)\n" in-dir out-dir (if cn->en? "CN→EN" "EN→CN"))
  (collect in-dir)
  (set! files-to-translate (reverse files-to-translate))
  
  ;; 检查冲突并一次性告知用户
  (define conflicts (for/list ([f (in-list files-to-translate)]
                               #:when (file-exists? (second f)))
                      (second f)))
  (unless (null? conflicts)
    (printf "\n以下 ~a 个输出文件已存在:\n" (length conflicts))
    (for ([c (in-list conflicts)]) (printf "  ~a\n" c))
    (printf "\n继续将覆盖这些文件。"))
  
  ;; 逐个翻译 (共享一个 confirm-box，confirm?=#f 则不确认)
  (define confirm-box (and confirm? (box #t)))
  (for ([f (in-list files-to-translate)])
    (match-define (list full-in full-out rel) f)
    (make-directory* (path-only full-out))
    (printf "  ~a -> ~a" rel (path->string full-out))
    (when (file-exists? full-out)
      (printf " (覆盖)"))
    (printf "\n")
    (translate-file full-in full-out #:direction dir #:confirm confirm-box)))
