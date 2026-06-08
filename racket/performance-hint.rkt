#lang racket/base
(require racket/performance-hint)

(provide
 (rename-out
   [begin-encourage-inline 开始鼓励内联]
   [define-inline 定义内联]))
