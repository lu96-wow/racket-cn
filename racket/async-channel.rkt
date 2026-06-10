#lang racket/base
(require racket/async-channel)
(require "../rename-macro.rkt")

(rename-define
  [async-channel/c 异步通道/合约]
  [async-channel? 异步通道?]
  [async-channel-get 异步通道-获取]
  [async-channel-put 异步通道-放入]
  [async-channel-put-evt 异步通道-放入事件]
  [async-channel-try-get 异步通道-尝试获取]
  [make-async-channel 制造异步通道]
)
