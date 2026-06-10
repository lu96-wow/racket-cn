#lang racket/base
(require racket/sequence)
(require "../rename-macro.rkt")

(rename-define
  [sequence-length 序列-长度]
  [sequence-ref 序列-引用]
  [sequence-tail 序列-尾部]
  [sequence-map 序列-映射]
  [sequence-append 序列-拼接]
  [sequence-filter 序列-过滤]
  [sequence-add-between 序列-加分隔]
  [sequence? 序列?]
  [sequence->list 序列->列表]
)
