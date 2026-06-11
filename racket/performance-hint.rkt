#lang racket/base
(require racket/performance-hint)
(require "../rename-macro.rkt")

(rename-define
  [begin-encourage-inline 开始-鼓励-内联]
  [define-inline 定义-内联]
)
