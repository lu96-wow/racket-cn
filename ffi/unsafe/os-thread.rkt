#lang racket/base
(require ffi/unsafe/os-thread)
(require "../../rename-macro.rkt")

(rename-define
  [call-in-os-thread 在OS线程调用]
  [make-os-semaphore 制造OS信号量]
  [os-semaphore-post OS信号量-发送]
  [os-semaphore-wait OS信号量-等待]
  [os-thread-enabled? OS线程已启用?]
)
