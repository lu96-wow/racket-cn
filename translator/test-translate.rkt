#lang racket/base

(require rackunit
         racket/file
         racket/path
         racket/port
         racket/string
         "main.rkt"
         "private/core.rkt")

;; ── helpers ────────────────────────────────────────────

(define counter 0)
(define (translate-string str direction)
  (set! counter (add1 counter))
  (define in-file (make-temporary-file (format "test-in-~a-~~a.rkt" counter)))
  (define out-file (make-temporary-file (format "test-out-~a-~~a.rkt" counter)))
  (display-to-file str in-file #:exists 'replace)
  (parameterize ([current-output-port (open-output-nowhere)])
    (translate-file in-file out-file
                    #:direction direction
                    #:confirm #f))
  (define result (file->string out-file))
  (delete-file in-file)
  (delete-file out-file)
  result)

(define (en->cn s) (translate-string (string-append "#lang racket\n" s) 'en->cn))
(define (cn->en s) (translate-string (string-append "#lang racket-cn\n" s) 'cn->en))
(define (has? str sub) (check-true (string-contains? str sub) (format "~s not in ~s" sub str)))

;; ── tests ──────────────────────────────────────────────

(module+ test

  ;; 1. #lang line
  (test-case "#lang racket -> racket-cn"
    (has? (translate-string "#lang racket\n1" 'en->cn) "#lang racket-cn"))
  (test-case "#lang racket-cn -> racket"
    (has? (translate-string "#lang racket-cn\n1" 'cn->en) "#lang racket"))
  (test-case "#lang racket/base -> racket-cn/base"
    (has? (translate-string "#lang racket/base\n1" 'en->cn) "#lang racket-cn/base"))
  (test-case "#lang racket-cn/base -> racket/base"
    (has? (translate-string "#lang racket-cn/base\n1" 'cn->en) "#lang racket/base"))

  ;; 2. identifiers EN->CN
  (test-case "define -> 定义"   (has? (en->cn "(define x 1)") "定义"))
  (test-case "lambda -> 函数"   (has? (en->cn "(lambda (x) x)") "函数"))
  (test-case "if -> 如果"       (has? (en->cn "(if #t 1 2)") "如果"))
  (test-case "let -> 令"        (has? (en->cn "(let ([x 1]) x)") "令"))
  (test-case "displayln -> 显示行" (has? (en->cn "(displayln \"hi\")") "显示行"))
  (test-case "cons/car/cdr -> 对/首/尾"
    (let ([r (en->cn "(cons (car xs) (cdr xs))")])
      (has? r "对") (has? r "首") (has? r "尾")))

  ;; 3. identifiers CN->EN
  (test-case "定义 -> define"   (has? (cn->en "(定义 x 1)") "define"))
  (test-case "函数 -> lambda"   (has? (cn->en "(函数 (x) x)") "lambda"))
  (test-case "如果 -> if"       (has? (cn->en "(如果 #t 1 2)") "if"))
  (test-case "令 -> let"        (has? (cn->en "(令 ([x 1]) x)") "let"))
  (test-case "显示行 -> displayln" (has? (cn->en "(显示行 \"hi\")") "displayln"))

  ;; 4. keywords
  (test-case "#:exists -> #:如果存在" (has? (en->cn "#:exists") "#:如果存在"))
  (test-case "#:如果存在 -> #:exists" (has? (cn->en "#:如果存在") "#:exists"))
  (test-case "#:mode -> #:模式" (has? (en->cn "#:mode") "#:模式"))

  ;; 5. module paths in require
  (test-case "racket/list -> racket-cn/racket/list"
    (has? (en->cn "(require racket/list)") "racket-cn/racket/list"))
  (test-case "racket-cn/racket/list -> racket/list"
    (has? (cn->en "(require racket-cn/racket/list)") "racket/list"))
  (test-case "racket -> racket-cn"
    (has? (en->cn "(require racket)") "racket-cn"))
  (test-case "racket/base -> racket-cn/base"
    (has? (en->cn "(require racket/base)") "racket-cn/base"))

  ;; 6. special modules
  (test-case "json -> racket-cn/json"
    (has? (en->cn "(require json)") "racket-cn/json"))
  (test-case "racket-cn/json -> json"
    (has? (cn->en "(require racket-cn/json)") "json"))
  (test-case "ffi/unsafe -> racket-cn/ffi/unsafe"
    (has? (en->cn "(require ffi/unsafe)") "racket-cn/ffi/unsafe"))

  ;; 7. require sub-forms
  (test-case "for-syntax path translated"
    (let ([r (en->cn "(require (for-syntax racket/base))")])
      (has? r "for-syntax") (has? r "racket-cn/base")))
  (test-case "only-in path translated, ids preserved"
    (let ([r (en->cn "(require (only-in racket/list take drop))")])
      (has? r "only-in") (has? r "racket-cn/racket/list") (has? r "take") (has? r "drop")))

  ;; 8. roundtrip
  (test-case "roundtrip define"
    (let* ([en "#lang racket\n(define (f x) (* x x))"]
           [cn (translate-string en 'en->cn)]
           [back (translate-string cn 'cn->en)])
      (has? back "define") (has? back "(f x)")))
  (test-case "roundtrip require+identifiers"
    (let* ([en "#lang racket\n(require racket/list)\n(take '(1 2 3) 2)"]
           [cn (translate-string en 'en->cn)]
           [back (translate-string cn 'cn->en)])
      (has? back "racket/list") (has? back "take")))

  ;; 9. things that should NOT be translated
  (test-case "strings preserved"
    (let ([r (en->cn "(define msg \"hello world\")")])
      (has? r "hello world")))
  (test-case "numbers preserved"
    (has? (en->cn "(+ 1 2 3)") "(+ 1 2 3)"))

  ;; 10. update-translator-map
  (test-case "update-translator-map works"
    (define n (update-translator-map))
    (check-true (> n 1000) "Should have many mappings")))

(module+ main
  (printf "Use: raco test translator/test-translate.rkt\n"))
