#lang racket/base
(require racket/mutability)

(provide
 (rename-out
   [immutable-string? 不可变字符串?]
   [immutable-bytes? 不可变字节串?]
   [immutable-vector? 不可变向量?]
   [immutable-box? 不可变盒?]
   [immutable-hash? 不可变哈希?]
   [mutable-string? 可变字符串?]
   [mutable-bytes? 可变字节串?]
   [mutable-vector? 可变向量?]
   [mutable-box? 可变盒?]
   [mutable-hash? 可变哈希?]))
