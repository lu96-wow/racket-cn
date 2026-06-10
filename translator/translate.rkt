#lang racket/base

;; ============================================================
;; translate.rkt — racket ↔ racket-cn 双向翻译器
;;
;; 用法:
;;   racket translate.rkt <输入文件> [输出文件]
;;
;; 功能:
;;   1. #lang racket    ↔ #lang racket-cn
;;   2. #lang racket/xxx ↔ #lang racket-cn/xxx
;;   3. 标识符/关键字/关键字值 中英互译
;;   4. (require racket/xxx) ↔ (require racket-cn/racket/xxx)
;;   5. json, ffi/unsafe 等特殊模块路径转换
;; ============================================================

(require racket/list
         racket/string
         racket/file
         racket/path
         racket/match
         racket/pretty)

;; ── 加载映射表 ───────────────────────────────────────────

(define mapping-table
  (call-with-input-file
      (build-path (current-directory) "translator" "mappings-table.rktd")
    (lambda (p) (read p))))

;; 构建查找表
(define eng->cn (make-hash))
(define cn->eng (make-hash))
(define eng-kw->cn-kw (make-hash))     ;; 关键字名 eng→cn
(define cn-kw->eng-kw (make-hash))     ;; 关键字名 cn→eng
(define eng-kwv->cn-kwv (make-hash))   ;; 关键字值 eng→cn
(define cn-kwv->eng-kwv (make-hash))   ;; 关键字值 cn→eng

(for ([m (in-list mapping-table)])
  (match m
    [(list eng cn 'rename-define _)
     (hash-set! eng->cn eng cn)
     (hash-set! cn->eng cn eng)]
    [(list eng cn 'rename-define/for-syntax _)
     (hash-set! eng->cn eng cn)
     (hash-set! cn->eng cn eng)]
    [(list eng cn 'define-syntax _)
     (hash-set! eng->cn eng cn)
     (hash-set! cn->eng cn eng)]
    [(list eng cn '关键字 _)
     (hash-set! eng-kw->cn-kw eng cn)
     (hash-set! cn-kw->eng-kw cn eng)]
    [(list eng cn '关键字值 _)
     (hash-set! eng-kwv->cn-kwv eng cn)
     (hash-set! cn-kwv->eng-kwv cn eng)]
    [(list eng cn '关键字函数 _)
     (hash-set! eng->cn eng cn)
     (hash-set! cn->eng cn eng)]
    [_ (void)]))

(printf "已加载 ~a 条映射\n" (length mapping-table))
(printf "  标识符: ~a eng→cn, ~a cn→eng\n"
        (hash-count eng->cn) (hash-count cn->eng))
(printf "  关键字名: ~a, 关键字值: ~a\n"
        (hash-count eng-kw->cn-kw) (hash-count eng-kwv->cn-kwv))

;; ── 模块路径转换 ─────────────────────────────────────────

;; racket 的子模块列表（对应 racket-cn/racket/xxx）
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

;; 特殊顶层模块
(define special-modules-cn->en
  `(("racket-cn/json"       . ("json"))
    ("racket-cn/ffi/unsafe" . ("ffi" "unsafe"))
    ("racket-cn/ffi"        . ("ffi" "unsafe"))))

(define special-modules-en->cn
  `(("json"       . ("racket-cn" "json"))
    ("ffi/unsafe" . ("racket-cn" "ffi" "unsafe"))
    ("ffi"        . ("racket-cn" "ffi" "unsafe"))))

(define (translate-module-path path cn->en?)
  "翻译模块路径符号: cn->en?=#t 表示中文→英文
   路径是 racket/base 这样的单个符号，不是列表"
  (define s (symbol->string path))
  (cond
    ;; racket-cn → racket  (双向)
    [(string=? s "racket-cn")
     (if cn->en? 'racket 'racket-cn)]
    [(string=? s "racket")
     (if cn->en? 'racket 'racket-cn)]
    ;; racket-cn/base ↔ racket/base
    [(string=? s "racket-cn/base")
     (if cn->en? 'racket/base 'racket-cn/base)]
    [(string=? s "racket/base")
     (if cn->en? 'racket/base 'racket-cn/base)]
    ;; racket-cn/racket/xxx ↔ racket/xxx
    [(regexp-match #rx"^racket-cn/racket/(.+)$" s)
     => (lambda (m)
          (if cn->en?
              (string->symbol (format "racket/~a" (cadr m)))
              path))]
    [(regexp-match #rx"^racket/(.+)$" s)
     => (lambda (m)
          (define sub (cadr m))
          (if (member sub racket-submodules)
              (if cn->en? path (string->symbol (format "racket-cn/racket/~a" sub)))
              path))]
    ;; racket-cn/json → json, racket-cn/ffi/unsafe → ffi/unsafe
    [(regexp-match #rx"^racket-cn/json$" s)
     (if cn->en? 'json path)]
    [(regexp-match #rx"^racket-cn/ffi/(.+)$" s)
     => (lambda (m)
          (if cn->en? (string->symbol (format "ffi/~a" (cadr m))) path))]
    ;; json → racket-cn/json, ffi/unsafe → racket-cn/ffi/unsafe
    [(string=? s "json")
     (if cn->en? path 'racket-cn/json)]
    [(regexp-match #rx"^ffi/(.+)$" s)
     => (lambda (m)
          (if cn->en? path (string->symbol (format "racket-cn/ffi/~a" (cadr m)))))]
    ;; 默认不变
    [else path]))

;; ── 方向检测 ────────────────────────────────────────────

(define (detect-direction first-line)
  "检测翻译方向: #t=CN→EN, #f=EN→CN"
  (cond
    [(regexp-match #rx"^#lang +racket-cn" first-line) #t]
    [(regexp-match #rx"^#lang +racket" first-line) #f]
    [else #f]))

(define (translate-lang-line line cn->en?)
  "翻译 #lang 行"
  (cond
    [(regexp-match #rx"^#lang +racket-cn/base" line)
     (if cn->en? "#lang racket/base" "#lang racket-cn/base")]
    [(regexp-match #rx"^#lang +racket/base" line)
     (if cn->en? "#lang racket/base" "#lang racket-cn/base")]
    [(regexp-match #rx"^#lang +racket-cn" line)
     (if cn->en? "#lang racket" "#lang racket-cn")]
    [(regexp-match #rx"^#lang +racket" line)
     (if cn->en? "#lang racket" "#lang racket-cn")]
    [else line]))

;; ── 核心翻译递归 ─────────────────────────────────────────

(define (translate-expr expr cn->en?)
  "递归翻译 s-expression"
  (cond
    ;; 符号标识符
    [(symbol? expr)
     (let ([sym expr])
       (if cn->en?
           (hash-ref cn->eng sym sym)
           (hash-ref eng->cn sym sym)))]
    ;; 关键字 (#:xxx)
    [(keyword? expr)
     (let ([kw expr])
       (if cn->en?
           (hash-ref cn-kw->eng-kw kw kw)
           (hash-ref eng-kw->cn-kw kw kw)))]
    ;; 列表
    [(pair? expr)
     (let ([head (car expr)])
       (cond
         ;; (require ...) 特殊处理
         [(eq? head 'require)
          (translate-require expr cn->en?)]
         ;; 其他: 递归翻译每个元素
         [else
          (cons (translate-expr (car expr) cn->en?)
                (translate-expr/cdr (cdr expr) cn->en?))]))]
    ;; 其他原子值原样返回
    [else expr]))

(define (translate-expr/cdr rest cn->en?)
  "翻译列表的 cdr（处理可能的不当列表）"
  (cond
    [(pair? rest)
     (cons (translate-expr (car rest) cn->en?)
           (translate-expr/cdr (cdr rest) cn->en?))]
    [(null? rest) '()]
    [else (translate-expr rest cn->en?)]))

(define (translate-require expr cn->en?)
  "翻译 (require spec ...) 中的模块路径"
  (define (walk-spec spec)
    (match spec
      [(list 'for-syntax inner)
       (list 'for-syntax (walk-spec inner))]
      [(list 'for-label inner)
       (list 'for-label (walk-spec inner))]
      [(list 'for-meta n inner)
       (list 'for-meta n (walk-spec inner))]
      [(list 'for-template inner)
       (list 'for-template (walk-spec inner))]
      [(list 'only-in path ids ...)
       (list* 'only-in (translate-path path cn->en?) ids)]
      [(list 'except-in path ids ...)
       (list* 'except-in (translate-path path cn->en?) ids)]
      [(list 'prefix-in pfx path)
       (list 'prefix-in pfx (translate-path path cn->en?))]
      [(list 'rename-in path renames ...)
       (list* 'rename-in (translate-path path cn->en?) renames)]
      [(? symbol?) (translate-path spec cn->en?)]
      [(? string?) spec]  ;; 相对路径字符串不变
      [_ spec]))
  (cons 'require
        (for/list ([s (in-list (cdr expr))])
          (walk-spec s))))

(define (translate-path path cn->en?)
  "翻译 require/provide 中的模块路径（符号路径如 racket/base）"
  (cond
    [(symbol? path) (translate-module-path path cn->en?)]
    [else path]))

;; ── 主入口 ──────────────────────────────────────────────

(define (translate-file in-file out-file)
  "翻译整个文件"
  (define lines (file->lines in-file))
  
  ;; 检测方向
  (define cn->en? (detect-direction (first lines)))
  (printf "翻译方向: ~a\n" (if cn->en? "中文→英文" "英文→中文"))
  
  ;; 1. 翻译 #lang 行
  (define new-first-line (translate-lang-line (first lines) cn->en?))
  
  ;; 2. 读取剩余内容为 s-expression
  (define exprs
    (let ([port (open-input-string
                 (string-join (cons new-first-line (rest lines)) "\n"))])
      ;; 跳过 #lang 行
      (read-line port)
      (let loop ([acc '()])
        (let ([v (read port)])
          (if (eof-object? v)
              (begin (close-input-port port) (reverse acc))
              (loop (cons v acc)))))))
  
  ;; 3. 翻译所有表达式
  (define translated
    (for/list ([e (in-list exprs)])
      (translate-expr e cn->en?)))
  
  ;; 4. 输出
  (call-with-output-file out-file
    (lambda (port)
      (fprintf port "~a\n" new-first-line)
      (for ([e (in-list translated)])
        ;; 用 pretty-print 保留合理缩进
        (pretty-write e port)
        (newline port))))
  
  (printf "翻译完成: ~a -> ~a\n" in-file out-file))

;; ── 命令行接口 ──────────────────────────────────────────

(module+ main
  (define args (current-command-line-arguments))
  (unless (>= (vector-length args) 1)
    (eprintf "用法: racket translate.rkt <输入文件> [输出文件]\n")
    (exit 1))
  
  (define in-file (vector-ref args 0))
  (define out-file
    (if (>= (vector-length args) 2)
        (vector-ref args 1)
        (string-append
         (path-replace-extension in-file #f)
         (if (detect-direction (car (file->lines in-file)))
             ".en.rkt"
             ".cn.rkt"))))
  
  (translate-file in-file out-file))
