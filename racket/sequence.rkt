#lang racket/base
(require racket/sequence)
(require "../rename-macro.rkt")

(rename-define
  [empty-sequence 空序列]
  [sequence->list 序列->列表]
  [sequence-length 序列-长度]
  [sequence-ref 序列-引用]
  [sequence-tail 序列-尾部]
  [sequence-append 序列-拼接]
  [sequence-map 序列-映射]
  [sequence-andmap 序列-全映射]
  [sequence-ormap 序列-有映射]
  [sequence-for-each 序列-对每个]
  [sequence-fold 序列-折叠]
  [sequence-filter 序列-过滤]
  [sequence-add-between 序列-加分隔]
  [sequence-count 序列-计数]
  [sequence? 序列?]
  [in-syntax 在-语法]
)
