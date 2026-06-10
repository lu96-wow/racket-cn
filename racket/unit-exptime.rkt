#lang racket/base
(require racket/unit-exptime)
(require "../rename-macro.rkt")

(rename-define
  [unit-static-signatures 单元-静态-签名]
  [unit-static-init-dependencies 单元-静态-初始化-依赖]
  [signature-members 签名-成员]
)
