#lang racket/base
(require racket/syntax)
(require "../rename-macro.rkt")

(rename-define
  [define/with-syntax 定义/带-语法]
  [current-recorded-disappeared-uses 当前-记录-消失-使用]
  [with-disappeared-uses 带-消失-使用]
  [syntax-local-value/record 语法-局部-值/记录]
  [record-disappeared-uses 记录-消失-使用]
  [format-symbol 格式化-符号]
  [format-id 格式化-标识符]
  [current-syntax-context 当前-语法-上下文]
  [wrong-syntax 错误-语法]
  [generate-temporary 生成-临时]
  [internal-definition-context-apply 内部-定义-上下文-应用]
  [syntax-local-eval 语法-局部-求值]
  [with-syntax* 带-语法*]
)
