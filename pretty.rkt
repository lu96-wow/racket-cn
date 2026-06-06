#lang racket/base
(require racket/pretty)

(provide
 (rename-out
  [pretty-print        美化打印]
  [pretty-write        美化写出]
  [pretty-display      美化显示]
  [pretty-format       美化格式化]
  [pretty-printing     美化打印?]
  [pretty-print-columns  美化打印-列数]
  [pretty-print-depth    美化打印-深度]))
