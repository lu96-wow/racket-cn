#lang racket/base
(require racket/date)
(require "../rename-macro.rkt")

(rename-define
  [date? 日期?]
  [date->string 日期->字符串]
  [seconds->date 秒->日期]
  [date->seconds 日期->秒]
  [date-display-format 日期-显示格式]
  [find-seconds 查找-秒]
  [date* 日期*]
  [current-date 当前-日期]
)
