#lang racket/base
(require racket/os)
(require "../rename-macro.rkt")

(rename-define
  [gethostname 获取主机名]
  [getpid 获取进程ID]
)
