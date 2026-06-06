#lang racket/base
(require racket/random)

(provide
 (rename-out
  [random-seed            随机-种子]
  [crypto-random-bytes    加密随机字节]))
