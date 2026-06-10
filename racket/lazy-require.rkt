#lang racket/base
(require racket/lazy-require)
(require "../rename-macro.rkt")

(rename-define
  [lazy-require 延迟引用]
  [lazy-require-syntax 延迟引用语法]
)
