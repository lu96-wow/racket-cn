#lang racket/base
(require racket/stxparam
         "../rename-macro.rkt")

(rename-define
  [define-syntax-parameter 定义语法参数]
  [define-rename-transformer-parameter 定义重命名转换器参数]
  [syntax-parameterize 语法参数化])

(rename-define/for-syntax
  [syntax-parameter-value 语法参数值]
  [make-parameter-rename-transformer 制造参数重命名转换器])
