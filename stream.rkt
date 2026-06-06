#lang racket/base
(require racket/stream)
(provide
 (rename-out
  [stream 流]
  [stream? 流?]
  [stream-cons 流-对]
  [stream-first 流-首个]
  [stream-rest 流-剩余]
  [stream-ref 流-引用]
  [stream->list 流->列表]
  [in-stream 在流]
  [stream-map 流-映射]
  [stream-filter 流-过滤]
  [stream-fold 流-折叠]))
