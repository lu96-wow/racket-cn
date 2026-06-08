#lang racket/base
(require ffi/unsafe/global)

(provide
 (rename-out
   [register-process-global 注册进程全局]
   [get-place-table 获取位置表]))
