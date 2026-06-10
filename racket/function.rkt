#lang racket/base
(require racket/function)
(require "../rename-macro.rkt")

(rename-define
  [curry 柯里化]
  [curryr 右柯里化]
  [const 常量]
  [identity 恒等]
  [thunk 零参函数]
  [negate 取反]
)
