#lang racket/base
(require racket/bytes)
(require "../rename-macro.rkt")

(rename-define
  [bytes-append* 字节串-拼接*]
  [bytes-join 字节串-连接]
)
