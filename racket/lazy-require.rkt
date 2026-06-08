#lang racket/base
(require racket/lazy-require)

(provide
 (rename-out
   [lazy-require 延迟引用]
   [lazy-require-syntax 延迟引用语法]))
