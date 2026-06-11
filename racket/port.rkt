#lang racket/base
(require racket/port)
(require "../rename-macro.rkt")

(rename-define
  [call-with-input-string 调用-输入字符串]
  [call-with-output-string 调用-输出字符串]
  [call-with-input-bytes 调用-输入字节串]
  [call-with-output-bytes 调用-输出字节串]
  [copy-port 复制-端口]
  [port->list 端口->列表]
  [filter-read-input-port 过滤-读取-输入-端口]
  [dup-input-port 复制-输入-端口]
  [dup-output-port 复制-输出-端口]
)
