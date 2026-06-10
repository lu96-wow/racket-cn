#lang racket/base
(require racket/logging)
(require "../rename-macro.rkt")

(rename-define
  [with-intercepted-logging 带拦截日志]
  [with-logging-to-port 带日志到端口]
)
