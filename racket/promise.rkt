#lang racket/base
(require racket/promise)

(provide
 (rename-out
   [delay 延迟]
   [lazy 惰性]
   [force 求值]
   [promise? 承诺?]
   [promise-forced? 承诺已求值?]
   [promise-running? 承诺运行中?]
   [promise/name? 承诺/名称?]
   [delay/name 延迟/名称]
   [delay/strict 延迟/严格]
   [delay/sync 延迟/同步]
   [delay/thread 延迟/线程]
   [delay/idle 延迟/空闲]
   [for/list/concurrent 循环/列表/并发]
   [for*/list/concurrent 循环*/列表/并发]))
