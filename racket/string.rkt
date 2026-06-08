#lang racket/base
(require racket/string)
(provide
 (rename-out
  [string-contains? 字符串-包含?]
  [string-prefix? 字符串-前缀?]
  [string-suffix? 字符串-后缀?]
  [non-empty-string? 非空字符串?]))
