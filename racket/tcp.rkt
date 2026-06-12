#lang racket/base
(require racket/tcp)
(require "../rename-macro.rkt")

(rename-define
  [tcp-connect tcp-连接]
  [tcp-connect/enable-break tcp-连接/允许中断]
  [tcp-listen tcp-监听]
  [tcp-close tcp-关闭]
  [tcp-accept-ready? tcp-接受就绪?]
  [tcp-accept tcp-接受]
  [tcp-accept-evt tcp-接受事件]
  [tcp-accept/enable-break tcp-接受/允许中断]
  [tcp-listener? tcp-监听器?]
  [tcp-addresses tcp-地址]
  [tcp-abandon-port tcp-放弃端口]
  [tcp-port? tcp-端口?]
  [port-number? 端口-号?]
  [listen-port-number? 监听-端口-号?]
)
