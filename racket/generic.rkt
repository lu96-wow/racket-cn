#lang racket/base
(require racket/generic)

(provide
 (rename-out
   [define-generics 定义泛型]
   [define/generic 定义/泛型]
   [raise-support-error 引发支持错误]))
