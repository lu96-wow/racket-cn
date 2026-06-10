#lang racket/base
(require ffi/unsafe/alloc)
(require "../../rename-macro.rkt")

(rename-define
  [allocator 分配器]
  [deallocator 释放器]
  [releaser 释放器]
  [retainer 保持器]
)
