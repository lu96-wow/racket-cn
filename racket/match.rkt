#lang racket/base
(require racket/match)
(require "../rename-macro.rkt")

(rename-define
  [match 匹配]
  [match* 多匹配]
  [match-lambda 匹配-函数]
  [match-lambda* 匹配-多-函数]
  [match-let 匹配-令]
  [match-let* 依次-匹配-令]
  [match-let-values 匹配-令-多值]
  [match-define 匹配-定义]
)
