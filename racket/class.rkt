#lang racket/base
(require racket/class)
(require "../rename-macro.rkt")

(rename-define
  [class 类]
  [class* 类*]
  [new 新建]
  [send 发送]
  [send* 多发送]
  [define/public 定义/公开]
  [define/private 定义/私有]
  [define/override 定义/覆写]
  [field 字段]
  [init-field 初始-字段]
  [inherit 继承]
  [super 父类]
  [this 自身]
)
