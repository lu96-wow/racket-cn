#lang racket/base
(require racket/tcp)
(require "../rename-macro.rkt")

(rename-define
  [tcp-connect TCP-连接]
  [tcp-connect/enable-break TCP-连接/允许中断]
  [tcp-listen TCP-监听]
  [tcp-close TCP-关闭]
  [tcp-accept-ready? TCP-接受就绪?]
  [tcp-accept TCP-接受]
  [tcp-accept-evt TCP-接受事件]
  [tcp-accept/enable-break TCP-接受/允许中断]
  [tcp-listener? TCP-监听器?]
  [tcp-addresses TCP-地址]
  [tcp-abandon-port TCP-放弃端口]
  [tcp-port? TCP-端口?]
  [port-number? 端口号?]
  [listen-port-number? 监听端口号?]
)
