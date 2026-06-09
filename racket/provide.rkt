#lang racket/base
(require racket/provide
         (for-syntax racket/base))
(define-syntax 正则匹配导出 (make-rename-transformer #'matching-identifiers-out))
(define-syntax 过滤导出     (make-rename-transformer #'filtered-out))
(provide
 正则匹配导出 过滤导出)
