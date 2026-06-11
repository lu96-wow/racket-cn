#lang racket/base
(require racket/logging)
(require "../rename-macro.rkt")

(rename-define
  [with-intercepted-logging 带-拦截-日志]
  [with-logging-to-port 带-日志-到-端口]
)
