#lang racket/base
(require racket/file
         "kw.rkt"
         (for-syntax racket/base))

;; ============================================================
;; racket-cn/file — racket/file 的中文包装
;; ============================================================

;; 简单重命名
(provide
 (rename-out
  [file->string           文件->字符串]
  [file->bytes            文件->字节串]
  [file->lines            文件->行]
  [file->list             文件->列表]
  [file->value            文件->值]
  [file->bytes-lines      文件->字节行]
  [find-files             查找文件]
  [make-temporary-file    制造临时文件]))

;; 关键字函数
(定义-关键字函数 写入到文件 write-to-file
  (#:如果存在 #:exists (截断 truncate) (替换 replace) (追加 append)
                        (更新 update) (可更新 can-update))
  (#:模式 #:mode (文本 text) (字节 binary)))

(define-syntax (显示-到-文件 stx)
  (syntax-case stx ()
    [(_ 内容 路径) #'(display-to-file 内容 路径)]
    [(_ 内容 路径 关键字 ...) #'(display-to-file 内容 路径 关键字 ...)]))

(provide 写入到文件 显示-到-文件)
