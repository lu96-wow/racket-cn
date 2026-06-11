#lang racket/base
(require racket/path)
(require "../rename-macro.rkt")

(rename-define
  [normalize-path 规范化-路径]
  [resolve-path 解析-路径]
  [absolute-path? 绝对-路径?]
  [relative-path? 相对-路径?]
  [path-only 路径-仅目录]
  [path-replace-extension 路径-替换扩展名]
  [path-add-extension 路径-添加扩展名]
  [path-replace-suffix 路径-替换后缀]
  [path-add-suffix 路径-添加后缀]
  [split-path 拆分-路径]
  [explode-path 分解-路径]
  [simplify-path 简化-路径]
  [cleanse-path 清洗-路径]
  [current-directory-for-user 当前目录-用户]
)
