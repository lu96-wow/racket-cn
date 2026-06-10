#lang racket/base
(require racket/system)
(require "../rename-macro.rkt")

(rename-define
  [process 进程]
  [process* 进程*]
  [process/ports 进程/端口]
  [process*/ports 进程*/端口]
  [system 系统-执行]
  [system* 系统-执行*]
  [system/exit-code 系统-执行/退出码]
  [system*/exit-code 系统-执行*/退出码]
  [string-no-nuls? 字符串-无空字符?]
  [bytes-no-nuls? 字节-无空字符?]
  [system-type 系统-类型]
)
