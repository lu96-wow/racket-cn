#lang racket/base
(require racket/keyword-transform)
(require "../rename-macro.rkt")

(rename-define
  [syntax-procedure-alias-property 语法-过程-别名-属性]
  [syntax-procedure-converted-arguments-property 语法-过程-转换-参数-属性]
)
