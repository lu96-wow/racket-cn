#lang racket/base
(require racket/hash-code)
(require "../rename-macro.rkt")

(rename-define
  [hash-code-combine 哈希码-组合]
  [hash-code-combine* 哈希码-组合*]
  [hash-code-combine-unordered 哈希码-无序-组合]
  [hash-code-combine-unordered* 哈希码-无序-组合*]
)
