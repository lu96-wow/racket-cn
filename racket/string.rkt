#lang racket/base
(require racket/string)
(require "../rename-macro.rkt")

(rename-define
  [string-append* 字符串-拼接*]
  [string-join 字符串-连接]
  [string-trim 字符串-修剪]
  [string-normalize-spaces 字符串-规范化空格]
  [string-split 字符串-分割]
  [string-replace 字符串-替换]
  [non-empty-string? 非空-字符串?]
  [string-prefix? 字符串-前缀?]
  [string-suffix? 字符串-后缀?]
  [string-contains? 字符串-包含?]
  [string-find 字符串-查找]
)
