#lang racket/base
(require racket/place)
(require "../rename-macro.rkt")

(rename-define
  [place 位置]
  [place? 位置?]
  [place* 位置*]
  [place/context 位置/上下文]
  [dynamic-place 动态-位置]
  [dynamic-place* 动态-位置*]
  [place-channel 位置-通道]
  [place-channel? 位置-通道?]
  [place-channel-get 位置通道-获取]
  [place-channel-put 位置通道-放入]
  [place-channel-put/get 位置通道-放入/获取]
  [place-enabled? 位置-已启用?]
  [place-dead-evt 位置-死亡-事件]
  [place-break 位置-中断]
  [place-kill 位置-终止]
  [place-wait 位置-等待]
  [place-message-allowed? 位置-消息-允许?]
  [place-location? 位置-定位?]
  [processor-count 处理器-数量]
  [prop:place-location 属性:位置-定位]
)
