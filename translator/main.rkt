#lang racket/base

(require "private/collect.rkt"
         "private/core.rkt")

(provide update-translator-map
         en-to-cn
         cn-to-en
         en-to-cn-folder
         cn-to-en-folder
         en->cn-list
         cn->en-list
         query-mapping)

;; ── 更新映射表 ──────────────────────────────────────────

(define (update-translator-map)
  (define count (update-mapping-table!))
  (load-mapping-hashes)
  (printf "翻译器已重新加载 ~a 条映射\n" count)
  count)

;; ── 文件翻译 ────────────────────────────────────────────

(define (en-to-cn in-file out-file #:confirm? [confirm? #t])
  (translate-file in-file out-file #:direction 'en->cn
                  #:confirm (and confirm? (box #t))))

(define (cn-to-en in-file out-file #:confirm? [confirm? #t])
  (translate-file in-file out-file #:direction 'cn->en
                  #:confirm (and confirm? (box #t))))

;; ── 目录翻译 ────────────────────────────────────────────

(define (en-to-cn-folder in-dir out-dir #:confirm? [confirm? #t])
  (translate-directory in-dir out-dir #:direction 'en->cn #:confirm? confirm?))

(define (cn-to-en-folder in-dir out-dir #:confirm? [confirm? #t])
  (translate-directory in-dir out-dir #:direction 'cn->en #:confirm? confirm?))
