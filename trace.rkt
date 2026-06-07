#lang racket/base
(require racket/trace)

(provide
 (rename-out
  [trace                   跟踪]
  [untrace                 取消跟踪]
  [trace-call              跟踪调用]
  [trace-define            跟踪定义]
  [trace-let               跟踪令]
  [trace-lambda            跟踪函数]
  [trace-define-syntax     跟踪定义语法]
  [current-trace-print-results  当前跟踪打印结果]
  [current-trace-print-args     当前跟踪打印参数]
  [current-trace-notify         当前跟踪通知]
  [current-prefix-out           当前前缀出]
  [current-prefix-in            当前前缀入]))
