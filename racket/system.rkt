#lang racket/base
(require racket/system)
(require "../rename-macro.rkt")

(rename-define
  [system 系统-执行]
  [system* 系统-执行*]
  [system/exit-code 系统-执行/退出码]
  [system-type 系统-类型]
)
