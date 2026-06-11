#lang racket/base
(require racket/trace)
(require "../rename-macro.rkt")

(rename-define
  [trace 跟踪]
  [untrace 取消跟踪]
  [trace-call 跟踪-调用]
  [trace-define 跟踪-定义]
  [trace-let 跟踪-令]
  [trace-lambda 跟踪-函数]
  [trace-define-syntax 跟踪-定义-语法]
  [current-trace-print-results 当前-跟踪-打印-结果]
  [current-trace-print-args 当前-跟踪-打印-参数]
  [current-trace-notify 当前-跟踪-通知]
  [current-prefix-out 当前-前缀-出]
  [current-prefix-in 当前-前缀-入]
)
