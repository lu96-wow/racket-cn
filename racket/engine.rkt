#lang racket/base
(require racket/engine)
(require "../rename-macro.rkt")

(rename-define
  [engine? 引擎?]
  [engine 引擎]
  [engine-kill 引擎-终止]
  [engine-result 引擎-结果]
  [engine-run 引擎-运行]
)
