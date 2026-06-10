#lang racket/base
(require racket/performance-hint)
(require "../rename-macro.rkt")

(rename-define
  [begin-encourage-inline 开始鼓励内联]
  [define-inline 定义内联]
)
