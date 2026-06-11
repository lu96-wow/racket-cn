#lang racket/base
(require racket/stxparam
         "../rename-macro.rkt")

(rename-define
  [define-syntax-parameter 定义-语法-参数]
  [define-rename-transformer-parameter 定义-重命名-转换器-参数]
  [syntax-parameterize 语法-参数化])

(rename-define/for-syntax
  [syntax-parameter-value 语法-参数-值]
  [make-parameter-rename-transformer 制造-参数-重命名-转换器])
