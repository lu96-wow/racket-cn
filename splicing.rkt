#lang racket/base
(require racket/splicing)

(provide
 (rename-out
  [splicing-let                    拼接-令]
  [splicing-let-syntax             拼接-令语法]
  [splicing-let-syntaxes           拼接-令语法多]
  [splicing-letrec                 拼接-递归令]
  [splicing-letrec-syntax          拼接-递归令语法]
  [splicing-letrec-syntaxes        拼接-递归令语法多]
  [splicing-let-values             拼接-令多值]
  [splicing-letrec-values          拼接-递归令多值]
  [splicing-letrec-syntaxes+values 拼接-递归令语法多+多值]
  [splicing-local                  拼接-局部]
  [splicing-syntax-parameterize    拼接-语法参数化]
  [splicing-parameterize           拼接-参数化]))
