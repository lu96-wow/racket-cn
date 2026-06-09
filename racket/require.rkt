#lang racket/base
(require racket/require
         (for-syntax racket/base))
(define-syntax 正则匹配导入 (make-rename-transformer #'matching-identifiers-in))
(define-syntax 减去导入     (make-rename-transformer #'subtract-in))
(define-syntax 过滤导入     (make-rename-transformer #'filtered-in))
(define-syntax 向上查找路径 (make-rename-transformer #'path-up))
(define-syntax 多重导入     (make-rename-transformer #'multi-in))
(provide
 正则匹配导入 减去导入 过滤导入 向上查找路径 多重导入)
