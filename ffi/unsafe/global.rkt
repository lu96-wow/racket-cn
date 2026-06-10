#lang racket/base
(require ffi/unsafe/global)
(require "../../rename-macro.rkt")

(rename-define
  [register-process-global 注册进程全局]
  [get-place-table 获取位置表]
)
