#lang racket/base
(require racket/bool)
(require "../rename-macro.rkt")

(rename-define
  [true 真]
  [false 假]
  [false? 假?]
  [boolean=? 布尔=?]
  [symbol=? 符号=?]
  [implies 蕴含]
  [nand 与非]
  [nor 或非]
  [xor 异或]
)
