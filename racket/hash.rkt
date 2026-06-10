#lang racket/base
(require racket/hash)
(require "../rename-macro.rkt")

(rename-define
  [hash-union 哈希-并集]
  [hash-intersect 哈希-交集]
  [hash-keys-subset? 哈希-键子集?]
  [hash-empty? 哈希-空?]
  [hash-map 哈希-映射]
  [hash-for-each 哈希-遍历]
  [hash-filter 哈希-过滤]
  [hash-filter-keys 哈希-过滤键]
  [hash-filter-values 哈希-过滤值]
)
