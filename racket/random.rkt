#lang racket/base
(require racket/random)
(require "../rename-macro.rkt")

(rename-define
  [random-seed 随机-种子]
  [crypto-random-bytes 加密-随机-字节]
)
