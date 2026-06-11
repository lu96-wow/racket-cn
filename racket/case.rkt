#lang racket/base
(require racket/case)
(require "../rename-macro.rkt")

(rename-define
  [case/equal 分支/等值]
  [case/equal-always 分支/等值-始终]
  [case/eq 分支/等同]
  [case/eqv 分支/等价]
)
