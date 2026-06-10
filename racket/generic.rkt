#lang racket/base
(require racket/generic)
(require "../rename-macro.rkt")

(rename-define
  [define-generics 定义泛型]
  [define/generic 定义/泛型]
  [raise-support-error 引发支持错误]
)
