#lang racket/base
(require racket/runtime-path)
(require "../rename-macro.rkt")

(rename-define
  [define-runtime-path 定义-运行时-路径]
  [define-runtime-paths 定义-运行时-路径组]
  [define-runtime-path-list 定义-运行时-路径-列表]
  [define-runtime-module-path-index 定义-运行时-模块-路径-索引]
  [runtime-require 运行时-引用]
  [runtime-paths 运行时-路径组]
)
