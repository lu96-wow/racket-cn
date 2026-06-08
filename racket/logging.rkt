#lang racket/base
(require racket/logging)

(provide
 (rename-out
   [with-intercepted-logging 带拦截日志]
   [with-logging-to-port 带日志到端口]))
