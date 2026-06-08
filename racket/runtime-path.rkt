#lang racket/base
(require racket/runtime-path)

(provide
 (rename-out
   [define-runtime-path 定义运行时路径]
   [define-runtime-paths 定义运行时路径组]
   [define-runtime-path-list 定义运行时路径列表]
   [define-runtime-module-path-index 定义运行时模块路径索引]
   [runtime-require 运行时引用]
   [runtime-paths 运行时路径组]))
