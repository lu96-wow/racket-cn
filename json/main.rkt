#lang racket/base
(require json)

(provide
 (rename-out
  [json-null       JSON-空值]
  [jsexpr?         JSON表达式?]
  [write-json      写出JSON]
  [read-json       读取JSON]
  [jsexpr->string  JSON表达式->字符串]
  [jsexpr->bytes   JSON表达式->字节串]
  [string->jsexpr  字符串->JSON表达式]
  [bytes->jsexpr   字节串->JSON表达式]))
