#lang racket/base
(require racket/struct-info)
(require "../rename-macro.rkt")

(rename-define
  [struct-info? 结构-信息?]
  [checked-struct-info? 检查-结构-信息?]
  [struct-auto-info? 结构-自动-信息?]
  [struct-auto-info-lists 结构-自动-信息-列表]
  [struct-field-info? 结构-字段-信息?]
  [struct-field-info-list 结构-字段-信息-列表]
  [make-struct-info 制造-结构-信息]
  [extract-struct-info 提取-结构-信息]
)
