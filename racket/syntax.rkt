#lang racket/base
(require racket/syntax)
(require "../rename-macro.rkt")

(rename-define
  [define/with-syntax 定义/带语法]
  [current-recorded-disappeared-uses 当前记录消失使用]
  [with-disappeared-uses 带消失使用]
  [syntax-local-value/record 语法局部值/记录]
  [record-disappeared-uses 记录消失使用]
  [format-symbol 格式化符号]
  [format-id 格式化标识符]
  [current-syntax-context 当前语法上下文]
  [wrong-syntax 错误语法]
  [generate-temporary 生成临时]
  [internal-definition-context-apply 内部定义上下文应用]
  [syntax-local-eval 语法局部求值]
  [with-syntax* 带语法*]
)
