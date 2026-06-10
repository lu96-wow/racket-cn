#lang racket/base
(require racket/pretty)
(require "../rename-macro.rkt")

(rename-define
  [pretty-print 美化-打印]
  [pretty-write 美化-写出]
  [pretty-display 美化-显示]
  [pretty-format 美化-格式化]
  [pretty-printing 美化-打印?]
  [pretty-print-columns 美化-打印-列数]
  [pretty-print-depth 美化-打印-深度]
)
