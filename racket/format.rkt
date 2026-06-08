#lang racket/base
(require racket/format)

(provide
 (rename-out
   [~a 格式化-显示]
   [~s 格式化-写出]
   [~v 格式化-值]
   [~e 格式化-指数]
   [~r 格式化-数字]
   [~.a 格式化-显示严格]
   [~.s 格式化-写出严格]
   [~.v 格式化-值严格]))
