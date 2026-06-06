#lang racket/base
(require racket/vector)

(provide
 (rename-out
  [vector-append          向量-拼接]
  [vector-copy            向量-复制]
  [vector-copy!           向量-复制!]
  [vector-map             向量-映射]
  [vector-map!            向量-映射!]
  [vector-filter          向量-过滤]
  [vector-filter-not      向量-过滤取反]
  [vector-count           向量-计数]
  [vector-member          向量-成员]
  [vector-memq            向量-成员等同]
  [vector-memv            向量-成员等价]
  [vector-argmin          向量-最小参数]
  [vector-argmax          向量-最大参数]
  [vector-immutable       向量-不可变]
  [vector-empty?          向量-空?]
  [vector-take            向量-取前]
  [vector-drop            向量-去掉前]
  [vector-split-at        向量-切分]
  [vector-take-right      向量-取后]
  [vector-drop-right      向量-去掉后]
  [vector-split-at-right  向量-右切分]
  [vector-sort            向量-排序]
  [vector-sort!           向量-排序!]))
