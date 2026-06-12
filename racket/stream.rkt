#lang racket/base
(require racket/stream)
(require "../rename-macro.rkt")

(rename-define
  [empty-stream 空流]
  [stream-cons 流-对]
  [stream? 流?]
  [stream-empty? 流-空?]
  [stream-first 流-首个]
  [stream-rest 流-剩余]
  [stream-lazy 流-惰性]
  [stream-force 流-求值]
  [in-stream 在-流]
  [stream 流]
  [stream* 流*]
  [stream->list 流->列表]
  [stream-length 流-长度]
  [stream-ref 流-引用]
  [stream-tail 流-尾部]
  [stream-take 流-取前]
  [stream-append 流-拼接]
  [stream-map 流-映射]
  [stream-andmap 流-全映射]
  [stream-ormap 流-有映射]
  [stream-for-each 流-对每个]
  [stream-fold 流-折叠]
  [stream-filter 流-过滤]
  [stream-add-between 流-加分隔]
  [stream-count 流-计数]
  [for/stream 循环/流]
  [for*/stream 循环*/流]
)
