#lang racket/base
(require racket/function)
(require "../rename-macro.rkt")

(rename-define
  [identity 恒等]
  [const 常量]
  [const* 常量*]
  [thunk 零参函数]
  [thunk* 零参函数*]
  [curry 柯里化]
  [curryr 右柯里化]
  [conjoin 联合]
  [disjoin 分离]
  [negate 取反]
)
