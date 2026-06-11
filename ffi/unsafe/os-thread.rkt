#lang racket/base
(require ffi/unsafe/os-thread)
(require "../../rename-macro.rkt")

(rename-define
  [call-in-os-thread 在-OS-线程-调用]
  [make-os-semaphore 制造-OS-信号量]
  [os-semaphore-post OS信号量-发送]
  [os-semaphore-wait OS信号量-等待]
  [os-thread-enabled? OS-线程-已启用?]
)
