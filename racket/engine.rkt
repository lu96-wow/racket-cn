#lang racket/base
(require racket/engine)

(provide
 (rename-out
   [engine? 引擎?]
   [engine 引擎]
   [engine-kill 引擎终止]
   [engine-result 引擎结果]
   [engine-run 引擎运行]))
