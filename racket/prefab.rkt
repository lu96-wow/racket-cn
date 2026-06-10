#lang racket/base
(require racket/prefab)
(require "../rename-macro.rkt")

(rename-define
  [immutable-prefab-struct-key 不可变预制结构键]
  [prefab-key-all-fields-immutable? 预制键全字段不可变?]
)
