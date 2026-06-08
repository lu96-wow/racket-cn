#lang racket/base
(require racket/struct-info)

(provide
 (rename-out
   [struct-info? 结构信息?]
   [checked-struct-info? 检查结构信息?]
   [struct-auto-info? 结构自动信息?]
   [struct-auto-info-lists 结构自动信息列表]
   [struct-field-info? 结构字段信息?]
   [struct-field-info-list 结构字段信息列表]
   [make-struct-info 制造结构信息]
   [extract-struct-info 提取结构信息]))
