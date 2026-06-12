#lang racket/base
(require ffi/unsafe/define)
(require "../../rename-macro.rkt")

(rename-define
  [define-ffi-definer 定义-ffi-定义器]
  [make-not-available 制造-不可用]
  [provide-protected 提供-受保护]
)
