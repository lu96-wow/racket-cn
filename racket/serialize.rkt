#lang racket/base
(require racket/serialize)
(require "../rename-macro.rkt")

(rename-define
  [define-serializable-struct 定义可序列化结构]
  [define-serializable-struct/versions 定义可序列化结构/版本]
  [serializable-struct 可序列化结构]
  [serializable-struct/versions 可序列化结构/版本]
)
