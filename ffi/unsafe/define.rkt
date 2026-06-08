#lang racket/base
(require ffi/unsafe/define)

(provide
 (rename-out
   [define-ffi-definer 定义FFI定义器]
   [make-not-available 制造不可用]
   [provide-protected 提供受保护]))
