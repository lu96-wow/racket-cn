#lang racket/base
(require racket/serialize-structs)
(require "../rename-macro.rkt")

(rename-define
  [prop:serializable 属性:可序列化]
  [make-serialize-info 制造-序列化-信息]
  [make-deserialize-info 制造-反序列化-信息]
)
