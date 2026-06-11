#lang racket/base
(require racket/mutability)
(require "../rename-macro.rkt")

(rename-define
  [immutable-string? 不可变-字符串?]
  [immutable-bytes? 不可变-字节串?]
  [immutable-vector? 不可变-向量?]
  [immutable-box? 不可变-盒?]
  [immutable-hash? 不可变-哈希?]
  [mutable-string? 可变-字符串?]
  [mutable-bytes? 可变-字节串?]
  [mutable-vector? 可变-向量?]
  [mutable-box? 可变-盒?]
  [mutable-hash? 可变-哈希?]
)
