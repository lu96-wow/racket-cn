#lang racket/base
(require racket/match)
(provide
 (rename-out
  [match 匹配]
  [match* 多匹配]
  [match-lambda 匹配函数]
  [match-lambda* 匹配多函数]
  [match-let 匹配令]
  [match-let* 依次匹配令]
  [match-let-values 匹配令多值]
  [match-define 匹配定义]))
