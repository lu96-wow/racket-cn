#lang racket/base
(require racket/generator)
(require "../rename-macro.rkt")

(rename-define
  [generator 生成器]
  [generator-state 生成器-状态]
  [in-generator 在生成器中]
  [infinite-generator 无限生成器]
  [sequence->generator 序列->生成器]
)
