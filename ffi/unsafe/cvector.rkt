#lang racket/base
(require ffi/unsafe/cvector)
(require "../../rename-macro.rkt")

(rename-define
  [cvector C向量]
  [cvector? C向量?]
  [cvector-length C向量-长度]
  [cvector-ref C向量-引用]
  [cvector-set! C向量-设置!]
  [cvector-type C向量-类型]
  [cvector-ptr C向量-指针]
  [make-cvector 制造-C向量]
)
