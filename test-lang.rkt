#lang racket/base
(require (for-syntax racket/base) (for-syntax "racket/base-impl.rkt") "main.rkt")

(显示 "=== racket-cn ===\n")

;; 函数
(printf "null:~a void:~a\n" 空值 (空))
(printf "number?:~a string?:~a\n" (数字? 42) (字符串? "hi"))

;; 特殊形式
(printf "if:~a\n" (如果 #t "ok" "no"))
(定义 x (顺序求值 (显示行 "  begin") 42))
(printf "lambda:~a\n" ((函数 (y) (* y 2)) 21))

;; 关键字
(写入到文件 "kw-test" "/tmp/ck.txt" #:如果存在 '截断)
(printf "kw:~a" (文件->字符串 "/tmp/ck.txt"))

;; for/ 系列
(printf "for/list:~a\n" (循环/列表 ([x (在-范围 3)]) x))
(printf "for/fold:~a\n" (循环/折叠 ([s 0]) ([x (在-范围 4)]) (+ s x)))
(printf "for*/list:~a\n" (循环*/列表 ([x (在-范围 2)] [y (在-范围 2)]) (列表 x y)))

;; 子模块
(printf "hash:~a vec:~a date:~a\n" (哈希-空? (哈希)) (向量-空? (向量)) (日期? (当前-日期)))
(printf "list:~a str:~a\n" (取前 (范围 5) 2) (字符串-包含? "abc" "b"))

;; 宏定义 - syntax-case
(定义-语法 (tm stx)
  (语法-匹配 stx () [(_ x) #'x]))
(printf "syntax-case:~a\n" (tm 99))

;; 宏定义 - with-syntax
(定义-语法 (tm2 stx)
  (语法-匹配 stx () [(_ x) (带-语法 ([y #'(+ x 1)]) #'y)]))
(printf "with-syntax:~a\n" (tm2 41))

;; 标识符
(printf "free-id=? ~a bound-id=? ~a\n"
  (自由-标识符-等同? #'x #'x)
  (绑定-标识符-等同? #'x #'x 0))

;; 应用宏
(printf "match:~a cc:~a\n"
  (匹配 42 [x x])
  (续延 (函数 (c) (c 100))))

(显示 "Done\n")
