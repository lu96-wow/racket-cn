#lang racket/base
(require racket/system)

(provide
 (rename-out
  [system                 系统-执行]
  [system*                系统-执行*]
  [system/exit-code       系统-执行/退出码]
  [system-type            系统-类型]))
