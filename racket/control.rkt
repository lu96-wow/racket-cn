#lang racket/base
(require racket/control)

(provide
 (rename-out
   [call/prompt 调用/提示]
   [call/comp 调用/组合]
   [abort/cc 中止/续延]
   [abort 中止]
   [fcontrol F控制]
   [% 百分号]
   [control 控制]
   [prompt 提示]
   [control-at 控制在]
   [prompt-at 提示在]
   [shift 位移]
   [reset 重置]
   [shift-at 位移在]
   [reset-at 重置在]
   [control0 控制0]
   [prompt0 提示0]
   [control0-at 控制0在]
   [prompt0-at 提示0在]
   [shift0 位移0]
   [reset0 重置0]
   [shift0-at 位移0在]
   [reset0-at 重置0在]
   [spawn 生成]
   [splitter 分割器]
   [new-prompt 新提示]
   [set 设置]
   [cupto 直到]))
