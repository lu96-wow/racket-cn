#lang racket/base
(require racket/date)

(provide
 (rename-out
  [date?                   日期?]
  [date->string            日期->字符串]
  [seconds->date           秒->日期]
  [date->seconds           日期->秒]
  [date-display-format     日期-显示格式]
  [find-seconds            查找秒]
  [date*                   日期*]
  [current-date            当前日期]))
