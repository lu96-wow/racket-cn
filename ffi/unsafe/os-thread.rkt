#lang racket/base
(require ffi/unsafe/os-thread)
(require "../../rename-macro.rkt")

(rename-define
  [call-in-os-thread 在-os-线程-调用]
  [make-os-semaphore 制造-os-信号量]
  [os-semaphore-post os信号量-发送]
  [os-semaphore-wait os信号量-等待]
  [os-thread-enabled? os-线程-已启用?]
)
