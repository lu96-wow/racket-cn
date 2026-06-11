#lang racket/base
(require racket/include)
(require "../rename-macro.rkt")

(rename-define
  [include 包含]
  [include-at/relative-to 包含-在/相对]
  [include/reader 包含/读取器]
  [include-at/relative-to/reader 包含-在/相对/读取器]
)
