#lang racket/base
(require racket/bytes)

(provide
 (rename-out
   [bytes-append* 字节串-拼接*]
   [bytes-join 字节串-连接]))
