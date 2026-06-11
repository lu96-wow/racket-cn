#lang racket/base
(require racket/lazy-require)
(require "../rename-macro.rkt")

(rename-define
  [lazy-require 延迟-引用]
  [lazy-require-syntax 延迟-引用-语法]
)
