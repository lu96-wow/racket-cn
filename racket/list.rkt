#lang racket/base
(require racket/list)
(require "../rename-macro.rkt")

(rename-define
  [take 取前]
  [drop 去掉前]
  [split-at 分割-在]
  [take-right 取-后]
  [drop-right 去掉-后]
  [split-at-right 分割-在-右]
  [append-map 拼接-映射]
  [filter-map 过滤-映射]
  [count 计数]
  [argmin 最小参数]
  [argmax 最大参数]
  [group-by 分组-按]
  [remove 移除]
  [remq 移除等同]
  [remv 移除等价]
  [remove* 多移除]
  [sort 排序]
  [flatten 展平]
  [first 第一个]
  [second 第二个]
  [third 第三个]
  [fourth 第四个]
  [fifth 第五个]
  [rest 剩余]
  [last 最后一个]
  [cons? 有对?]
  [make-list 制造-列表]
  [range 范围]
)
