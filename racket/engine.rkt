#lang racket/base
(require racket/engine)
(require "../rename-macro.rkt")

(rename-define
  [engine? 引擎?]
  [engine 引擎]
  [engine-kill 引擎终止]
  [engine-result 引擎结果]
  [engine-run 引擎运行]
)
