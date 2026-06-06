#lang racket/base
(require racket/set)
(provide
 (rename-out
  [set 集合]
  [set? 集合?]
  [set-add 集合-添加]
  [set-remove 集合-移除]
  [set-count 集合-计数]
  [set-member? 集合-成员?]
  [set-union 集合-并集]
  [set-intersect 集合-交集]
  [set-subtract 集合-差集]
  [list->set 列表->集合]
  [set->list 集合->列表]
  [set-copy 集合-复制]
  [set-map 集合-映射]))
