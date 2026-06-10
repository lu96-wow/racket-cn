#lang racket/base
(require racket/place)
(require "../rename-macro.rkt")

(rename-define
  [place 位置]
  [place? 位置?]
  [place* 位置*]
  [place/context 位置/上下文]
  [dynamic-place 动态位置]
  [dynamic-place* 动态位置*]
  [place-channel 位置通道]
  [place-channel? 位置通道?]
  [place-channel-get 位置通道-获取]
  [place-channel-put 位置通道-放入]
  [place-channel-put/get 位置通道-放入/获取]
  [place-enabled? 位置已启用?]
  [place-dead-evt 位置死亡事件]
  [place-break 位置中断]
  [place-kill 位置终止]
  [place-wait 位置等待]
  [place-message-allowed? 位置消息允许?]
  [place-location? 位置定位?]
  [processor-count 处理器数量]
  [prop:place-location 属性:位置定位]
)
