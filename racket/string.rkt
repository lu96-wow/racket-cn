#lang racket/base
(require racket/string)
(require "../rename-macro.rkt")

(rename-define
  [string-contains? 字符串-包含?]
  [string-prefix? 字符串-前缀?]
  [string-suffix? 字符串-后缀?]
  [non-empty-string? 非空-字符串?]
)
