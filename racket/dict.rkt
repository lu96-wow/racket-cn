#lang racket/base
(require racket/dict)
(require "../rename-macro.rkt")

(rename-define
  [dict? 字典?]
  [dict-ref 字典-引用]
  [dict-set 字典-设置]
  [dict-remove 字典-移除]
  [dict-keys 字典-键]
  [dict-values 字典-值]
  [dict-count 字典-计数]
  [dict->list 字典->列表]
  [dict-copy 字典-复制]
  [dict-map 字典-映射]
)
