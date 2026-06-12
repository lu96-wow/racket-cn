#lang racket/base
(require json)
(require "../rename-macro.rkt")

(rename-define
  [json-null json-空值]
  [jsexpr? JSON表达式?]
  [write-json 写出-json]
  [read-json 读取-json]
  [jsexpr->string JSON表达式->字符串]
  [jsexpr->bytes JSON表达式->字节串]
  [string->jsexpr 字符串->JSON表达式]
  [bytes->jsexpr 字节串->JSON表达式]
)
