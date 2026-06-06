#lang racket/base

;; ============================================================
;; racket-cn/main — racket 的中文等价版本
;;
;; 提供方式：
;;   (require racket-cn)              ;; 模块引用
;;   #lang racket-cn                  ;; 语言使用
;;
;; 特性：
;;   - 包含 racket 全部功能
;;   - 包含 racket-cn/base 全部中文绑定
;;   - 额外常用功能的中文别名
;;   - 英文名和中文名可混用
;; ============================================================

(require racket
         "base-impl.rkt")

;; ============================================================
;; 1. 语言核心绑定
;; ============================================================
(provide
 #%module-begin
 #%app
 #%datum
 #%top)

;; ============================================================
;; 2. 全部英文原语透传（racket 的全部绑定）
;; ============================================================
(provide (all-from-out racket))

;; ============================================================
;; 3. 全部 base 的中文绑定
;; ============================================================
(provide (all-from-out "base-impl.rkt"))

;; ============================================================
;; 4. racket 额外的中文绑定
;;    （racket/base 没有，但 racket 提供的功能）
;; ============================================================
(provide
 (rename-out
  ;; 面向对象
  [class 类]
  [class* 类*]
  [new 新建]
  [send 发送]
  [send* 多发送]
  [define/public 定义/公开]
  [define/private 定义/私有]
  [define/override 定义/覆写]
  [field 字段]
  [init-field 初始字段]
  [inherit 继承]
  [super 父类]
  [this 自身]

  ;; 匹配
  [match 匹配]
  [match* 多匹配]
  [match-lambda 匹配函数]
  [match-lambda* 匹配多函数]
  [match-let 匹配令]
  [match-let* 依次匹配令]
  [match-let-values 匹配令多值]
  [match-define 匹配定义]

  ;; 合约
  [contract 合约]
  [contract-out 合约导出]
  [define/contract 定义/合约]
  [-> ->]
  [->i ->i]
  [any/c 任意/合约]
  [list/c 列表/合约]
  [vector/c 向量/合约]
  [integer-in 整数范围]
  [real-in 实数范围]
  [between/c 区间/合约]
  [or/c 或/合约]
  [and/c 且/合约]
  [not/c 非/合约]

  ;; 函数工具
  [curry 柯里化]
  [curryr 右柯里化]
  [const 常量]
  [identity 恒等]
  [thunk 零参函数]
  [negate 取反]

  ;; 额外列表操作
  [take 取前]
  [drop 去掉前]
  [split-at 切分]
  [take-right 取后]
  [drop-right 去掉后]
  [split-at-right 从右切分]
  [append-map 拼接映射]
  [filter-map 过滤映射]
  [count 计数]
  [argmin 最小参数]
  [argmax 最大参数]
  [group-by 分组]
  [remove 移除]
  [remq 移除等同]
  [remv 移除等价]
  [remove* 多移除]
  [sort 排序]
  [flatten 展平]

  ;; 集合
  [set 集合]
  [set? 集合?]
  [set-add 集合-添加]
  [set-remove 集合-移除]
  [set-count 集合-计数]
  [set-member? 集合-成员?]
  [set-union 集合-并集]
  [set-intersect 集合-交集]
  [set-subtract 集合-差集]
  [list->set 列表->集合]
  [set->list 集合->列表]

  ;; 字典接口
  [dict? 字典?]
  [dict-ref 字典-引用]
  [dict-set 字典-设置]
  [dict-remove 字典-移除]
  [dict-keys 字典-键]
  [dict-values 字典-值]
  [dict-count 字典-计数]
  [dict->list 字典->列表]

  ;; 流
  [stream 流]
  [stream? 流?]
  [stream-cons 流-对]
  [stream-first 流-首个]
  [stream-rest 流-剩余]
  [stream-ref 流-引用]
  [stream->list 流->列表]
  [in-stream 在流]

  ;; 额外字符串
  [string-join 字符串-连接]
  [string-split 字符串-切分]
  [string-replace 字符串-替换]
  [string-normalize-nfc 字符串-正规化NFC]
  [string-normalize-nfd 字符串-正规化NFD]

  ;; 系统/命令行
  [command-line 命令行]
  [exit 退出]

  ;; 延迟
  [delay 延迟]
  [force 求值]
  [promise? 承诺?]

  ;; 并发
  [future 未来]
  [touch 触碰]

  ;; 端口工具
  [call-with-input-string 调用-输入字符串]
  [call-with-output-string 调用-输出字符串]
  [call-with-input-bytes 调用-输入字节串]
  [call-with-output-bytes 调用-输出字节串]
  [copy-port 复制端口]
 ))

