#lang racket/base
(require racket/os)

(provide
 (rename-out
   [gethostname 获取主机名]
   [getpid 获取进程ID]))
