#lang racket/base
(require racket/contract)
(require "../rename-macro.rkt")

(rename-define
  [contract 合约]
  [contract-out 合约-导出]
  [define/contract 定义/合约]
  [any/c 任意/合约]
  [list/c 列表/合约]
  [vector/c 向量/合约]
  [integer-in 整数-范围]
  [real-in 实数-范围]
  [between/c 区间/合约]
  [or/c 或/合约]
  [and/c 且/合约]
  [not/c 非/合约]
)
