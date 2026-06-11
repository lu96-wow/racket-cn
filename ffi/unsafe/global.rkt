#lang racket/base
(require ffi/unsafe/global)
(require "../../rename-macro.rkt")

(rename-define
  [register-process-global 注册-进程-全局]
  [get-place-table 获取-位置-表]
)
