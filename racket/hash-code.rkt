#lang racket/base
(require racket/hash-code)

(provide
 (rename-out
   [hash-code-combine 哈希码组合]
   [hash-code-combine* 哈希码组合*]
   [hash-code-combine-unordered 哈希码无序组合]
   [hash-code-combine-unordered* 哈希码无序组合*]))
