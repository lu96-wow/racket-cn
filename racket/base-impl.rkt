#lang racket/base

;; ============================================================
;; racket-cn/base — racket/base 的中文等价版本
;;
;; 提供方式：
;;   (require racket-cn/base)        ;; 模块引用
;;   #lang racket-cn/base            ;; 语言使用
;;
;; 特性：
;;   - 所有英文原语均可使用（全部透传）
;;   - 常用原语有中文别名
;;   - 英文名和中文名可混用
;; ============================================================

(require racket/base "../kw.rkt")
(require (for-syntax racket/base))
(require "../rename-macro.rkt")

;; ============================================================
;; 1. 全部英文原语透传
;; ============================================================
(provide (all-from-out racket/base))

;; ============================================================
;; 2. 中文绑定
;; ============================================================

(rename-define
    ;; ========== 核心特殊形式 ==========
  [define 定义]
  [define-syntax 定义-语法]
  [define-syntax-rule 定义-语法-规则]
  [define-values 定义-多值]
  [lambda 函数]
  [case-lambda 分支-函数]
  [if 如果]
  [cond 条件]
  [else 否则]
  [case 分支]
  [let 令]
  [let* 依次令]
  [letrec 递归令]
  [let-values 令-多值]
  [let*-values 依次令-多值]
  [letrec-values 递归令-多值]
  [set! 赋值！]
  [begin 顺序求值]
  [begin0 顺序求值返回首个值]
  [when 当]
  [unless 除非]
  [and 且]
  [or 或]
  [not 非]
  [quote 引述]
  [quasiquote 准引用]
  [unquote 反引用]
  [quasisyntax 准语法]
  [unsyntax 反语法]
  [syntax 语法]
      ;; ========== 续延与控制 ==========
  [call/cc 续延]
  [call-with-current-continuation 调用-当前续延]
  [call-with-composable-continuation 调用-可组合续延]
  [call-with-escape-continuation 调用-逃逸续延]
  [call-with-continuation-prompt 调用-续延提示]
  [call-with-values 调用-多值]
  [dynamic-wind 动态-包裹]
  [raise 引发]
  [error 错误]
  [with-handlers 带-处理器]
      ;; ========== 布尔 ==========
  [boolean? 布尔?]
      ;; ========== 对与列表 ==========
  [cons 对]
  [car 首]
  [cdr 尾]
  [pair? 对?]
  [null 空值]
  [null? 空值?]
  [list 列表]
  [list? 列表?]
  [list* 列表*]
  [length 长度]
  [append 拼接]
  [reverse 反转]
  [member 成员]
  [assoc 关联查找]
  [caar 首首]
  [cadr 第二]
  [cdar 尾首]
  [cddr 尾尾]
      ;; ========== 映射与折叠 ==========
  [map 映射]
  [andmap 全映射]
  [ormap 有映射]
  [filter 过滤]
  [foldl 左折叠]
  [foldr 右折叠]
  [for-each 对-每个]
  [apply 应用]
  [compose 函数组合]
  [compose1 函数组合1]
  [values 多值]
      ;; ========== 数学 ==========
  [+ +]
  [abs 绝对值]
  [add1 加1]
  [sub1 减1]
  [expt 幂]
  [sqrt 平方根]
  [sin 正弦]
  [cos 余弦]
  [tan 正切]
  [floor 向下取整]
  [ceiling 向上取整]
  [round 四舍五入]
  [max 最大值]
  [min 最小值]
  [modulo 取模]
  [quotient 整除商]
  [remainder 余数]
  [even? 偶数?]
  [odd? 奇数?]
  [zero? 零?]
  [positive? 正?]
  [negative? 负?]
  [number? 数字?]
  [complex? 复数?]
  [real? 实数?]
  [integer? 整数?]
  [random 随机]
      ;; ========== 比较 ==========
  [eq? 等同?]
  [eqv? 等价?]
  [equal? 等值?]
      ;; ========== 字符串 ==========
  [string? 字符串?]
  [string 字符串]
  [string-append 字符串-拼接]
  [string-length 字符串-长度]
  [string-ref 字符串-引用]
  [substring 子字符串]
  [string->number 字符串->数字]
  [number->string 数字->字符串]
  [string->symbol 字符串->符号]
  [symbol->string 符号->字符串]
  [string->list 字符串->列表]
  [list->string 列表->字符串]
  [string=? 字符串=?]
  [string<? 字符串<?]
  [string>? 字符串>?]
  [string-ci=? 字符串-忽略大小写=?]
  [string-downcase 字符串-小写]
  [string-upcase 字符串-大写]
  [string-titlecase 字符串-首字母大写]
  [format 格式化]
      ;; ========== 字符 ==========
  [char? 字符?]
  [char->integer 字符->整数]
  [integer->char 整数->字符]
  [char=? 字符=?]
  [char-alphabetic? 字符-字母?]
  [char-numeric? 字符-数字?]
  [char-whitespace? 字符-空白?]
  [char-upcase 字符-大写]
  [char-downcase 字符-小写]
      ;; ========== 符号 ==========
  [symbol? 符号?]
  [gensym 生成唯一符号]
  [generate-temporaries 生成-临时-标识符]
      ;; ========== 关键字 ==========
  [keyword? 关键字?]
  [keyword->string 关键字->字符串]
  [string->keyword 字符串->关键字]
      ;; ========== 向量 ==========
  [vector 向量]
  [vector? 向量?]
  [vector-ref 向量-引用]
  [vector-set! 向量-赋值！]
  [vector-length 向量-长度]
  [make-vector 制造-向量]
  [vector->list 向量->列表]
  [list->vector 列表->向量]
  [vector-fill! 向量-填充！]
      ;; ========== 字节串 ==========
  [bytes 字节串]
  [bytes? 字节串?]
  [bytes-ref 字节串-引用]
  [bytes-length 字节串-长度]
  [make-bytes 制造-字节串]
  [bytes-append 字节串-拼接]
  [bytes-copy 字节串-复制]
      ;; ========== 哈希表 ==========
  [hash 哈希]
  [hash? 哈希?]
  [hash-ref 哈希-引用]
  [hash-set 哈希-设置]
  [hash-remove 哈希-移除]
  [hash-count 哈希-计数]
  [hash-keys 哈希-键]
  [hash-values 哈希-值]
  [hash->list 哈希->列表]
  [hash-copy 哈希-复制]
  [make-hash 制造-哈希]
  [hasheq 哈希等同]
  [hasheqv 哈希等价]
      ;; ========== 盒 ==========
  [box 盒]
  [box? 盒?]
  [unbox 开盒]
  [set-box! 盒-赋值！]
  [box-immutable 盒-不可变]
      ;; ========== 参数 ==========
  [make-parameter 制造-参数]
  [parameterize 参数化]
  [current-input-port 当前-输入-端口]
  [current-output-port 当前-输出-端口]
  [current-error-port 当前-错误-端口]
  [current-directory 当前-目录]
      ;; ========== 输入输出 ==========
  [display 显示]
  [displayln 显示行]
  [print 打印]
  [println 打印行]
  [write 写出]
  [printf 格式化输出]
  [read 读取]
  [read-line 读取-行]
  [read-string 读取-字符串]
  [read-bytes 读取-字节串]
  [read-char 读取-字符]
  [peek-char 窥视-字符]
  [newline 换行]
  [open-input-string 打开-输入-字符串]
  [open-output-string 打开-输出-字符串]
  [close-input-port 关闭-输入-端口]
  [close-output-port 关闭-输出-端口]
  [port? 端口?]
  [input-port? 输入-端口?]
  [output-port? 输出-端口?]
  [eof 文件尾]
  [eof-object? 文件尾-对象?]
      ;; ========== 文件系统 ==========
  [file-exists? 文件-存在?]
  [directory-exists? 目录-存在?]
  [delete-file 删除-文件]
  [make-directory 创建-目录]
  [copy-file 复制-文件]
  [path? 路径?]
  [path->string 路径->字符串]
  [find-system-path 查找-系统-路径]
  [build-path 构建-路径]
  [raise-argument-error 引发-参数-错误]
  [raise-syntax-error 引发-语法-错误]
      ;; ========== 线程 ==========
  [thread? 线程?]
  [sleep 睡眠]
  [kill-thread 终止-线程]
  [current-thread 当前-线程]
  [break-thread 中断-线程]
  [make-semaphore 制造-信号量]
  [semaphore-post 信号量-发送]
  [semaphore-wait 信号量-等待]
      ;; ========== 结构 ==========
  [struct 结构]
  [struct? 结构?]
      ;; ========== 异常 ==========
  [exn 异常]
  [exn? 异常?]
  [raise 引发]
  [error 错误]
  [with-handlers 带-处理器]
      ;; ========== 宏/语法 ==========
  [identifier? 标识符?]
  [syntax->datum 语法->数据]
  [datum->syntax 数据->语法]
  [syntax-rules 语法-规则]
  [syntax-case 语法-匹配]
  [with-syntax 带-语法]
  [begin-for-syntax 编译期-开始]
  [define-for-syntax 编译期-定义]
  [syntax-e 语法-值]
  [syntax->list 语法->列表]
  [syntax-source 语法-源]
  [syntax-line 语法-行]
  [syntax-column 语法-列]
  [syntax-position 语法-位置]
  [free-identifier=? 自由-标识符-等同?]
  [bound-identifier=? 绑定-标识符-等同?]
  [identifier-binding 标识符-绑定]
  [let-syntax 令-语法]
  [letrec-syntax 递归令-语法]
  [let-syntaxes 令-语法-多]
  [letrec-syntaxes 递归令-语法-多]
  [local-expand 局部-展开]
  [make-rename-transformer 制造-重命名-转换器]
      ;; ========== 迭代/循环 ==========
  [for 循环]
  [for* 循环*]
  [for/list 循环/列表]
  [for*/list 循环*/列表]
  [for/vector 循环/向量]
  [for*/vector 循环*/向量]
  [for/and 循环/且]
  [for*/and 循环*/且]
  [for/or 循环/或]
  [for*/or 循环*/或]
  [for/first 循环/首个]
  [for*/first 循环*/首个]
  [for/last 循环/末个]
  [for*/last 循环*/末个]
  [for/fold 循环/折叠]
  [for*/fold 循环*/折叠]
  [for-each 对-每个]
  [in-range 在-范围]
  [in-list 在-列表]
  [in-vector 在-向量]
  [in-string 在-字符串]
  [in-bytes 在-字节串]
  [in-hash 在-哈希]
  [in-naturals 在-自然数]
  [in-port 在-端口]
      ;; ========== 多值 ==========
  [define-values 定义-多值]
  [let-values 令-多值]
  [let*-values 依次令-多值]
  [call-with-values 调用-多值]
  [values 多值]
      ;; ========== 命名空间 ==========
  [dynamic-require 动态-引用]
  [current-namespace 当前-命名空间]
  [make-base-namespace 制造-基础-命名空间]
  [namespace-variable-value 命名空间-变量-值]
      ;; ========== 系统 ==========
  [exit 退出]
  [collect-garbage 回收-垃圾]
  [version 版本]
  [current-milliseconds 当前-毫秒]
  [current-seconds 当前-秒]
      ;; ========== 类型谓词 ==========
  [void 空]
  [void? 空?]
)
;; 4. 关键字函数中文包装（宏翻译 #:如果存在 → #:exists 等）
;; ============================================================
(定义-关键字函数 打开-输入-文件 open-input-file
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:为模块? #:for-module?))

(定义-关键字函数 打开-输出-文件 open-output-file
          (#:如果存在 #:exists (错误 error) (截断 truncate) (替换 replace)
           (追加 append) (更新 update) (可更新 can-update)
           (必须截断 must-truncate) (截断或替换 truncate/replace))
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:权限 #:permissions)
          (#:替换权限? #:replace-permissions?))

(定义-关键字函数 打开-输入-输出-文件 open-input-output-file
          (#:如果存在 #:exists (错误 error) (截断 truncate) (替换 replace)
           (追加 append) (更新 update) (可更新 can-update)
           (必须截断 must-truncate) (截断或替换 truncate/replace))
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:权限 #:permissions)
          (#:替换权限? #:replace-permissions?))

(定义-关键字函数 调用-输入-文件 call-with-input-file
          (#:模式 #:mode (二进制 binary) (文本 text)))

(定义-关键字函数 调用-输出-文件 call-with-output-file
          (#:如果存在 #:exists (错误 error) (截断 truncate) (替换 replace)
           (追加 append) (更新 update) (可更新 can-update)
           (必须截断 must-truncate) (截断或替换 truncate/replace))
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:权限 #:permissions)
          (#:替换权限? #:replace-permissions?))

(定义-关键字函数 调用-输入-文件* call-with-input-file*
          (#:模式 #:mode (二进制 binary) (文本 text)))

(定义-关键字函数 调用-输出-文件* call-with-output-file*
          (#:如果存在 #:exists (错误 error) (截断 truncate) (替换 replace)
           (追加 append) (更新 update) (可更新 can-update)
           (必须截断 must-truncate) (截断或替换 truncate/replace))
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:权限 #:permissions)
          (#:替换权限? #:replace-permissions?))

(定义-关键字函数 以-文件-输入 with-input-from-file
          (#:模式 #:mode (二进制 binary) (文本 text)))

(定义-关键字函数 以-文件-输出 with-output-to-file
          (#:如果存在 #:exists (错误 error) (截断 truncate) (替换 replace)
           (追加 append) (更新 update) (可更新 can-update)
           (必须截断 must-truncate) (截断或替换 truncate/replace))
          (#:模式 #:mode (二进制 binary) (文本 text))
          (#:权限 #:permissions)
          (#:替换权限? #:replace-permissions?))

(定义-关键字函数 线程 thread
          (#:池 #:pool (独自 own))
          (#:保留 #:keep (结果 results)))

(provide 打开-输入-文件 打开-输出-文件 打开-输入-输出-文件
         调用-输入-文件 调用-输出-文件 调用-输入-文件* 调用-输出-文件*
         以-文件-输入 以-文件-输出 线程)