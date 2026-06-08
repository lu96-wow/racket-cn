#lang racket/base
(require racket/case)

(provide
 (rename-out
   [case/equal 分支/等值]
   [case/equal-always 分支/等值始终]
   [case/eq 分支/等同]
   [case/eqv 分支/等价]))
