#lang racket-cn
;; 需要 phase-1 中文绑定时显式 import（和标准 Racket 一致）
(require (for-syntax racket-cn/base)
         racket-cn/racket/math
         racket-cn/racket/bool
         racket-cn/racket/fixnum
         racket-cn/racket/flonum
         racket-cn/racket/struct)

(显示 "=== racket-cn 全面测试 ===\n")

;; 1. 核心特殊形式
(定义 x 42)
(定义 (平方 y) (* y y))
(printf "1. 核心: 定义=~a 平方=~a 且/非=~a 如果=~a\n" x (平方 3) (且 #t (非 #f)) (如果 #t "ok" "no"))

;; 2. 令
(令 ([a 1] [b 2])
  (printf "2. 令: ~a ~a ~a\n" a b (递归令 ([f (如果 #t 99 0)]) f)))

;; 3. 列表
(定义 lst (列表 1 2 3 4 5))
(printf "3. 列表: 首=~a 长=~a 映射=~a 过滤=~a\n"
  (首 lst) (长度 lst) (映射 加1 lst) (过滤 偶数? lst))

;; 4. 关键字参数
(写入到文件 "kw-test" "/tmp/ck3.txt" #:如果存在 '截断 #:模式 '文本)
(printf "4. 关键字: ~a\n" (文件->字符串 "/tmp/ck3.txt"))

;; 5. 宏 — syntax-case phase-1
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ a) #'a]
    [(_ a b ...) #'(令 ([t a]) (如果 t t (my-or b ...)))]))
(printf "5. 宏-syntax-case: ~a\n" (my-or #f #f 42 #f))

;; 6. 宏 — with-syntax phase-1
(定义语法 (add1-macro stx)
  (语法匹配 stx () [(_ x) (带语法 ([y #'(+ x 1)]) #'y)]))
(printf "6. 宏-with-syntax: ~a\n" (add1-macro 41))

;; 7. for 系列
(printf "7. for: /list=~a /fold=~a /and=~a\n"
  (循环/列表 ([i (在范围 3)]) i)
  (循环/折叠 ([s 0]) ([i (在范围 4)]) (+ s i))
  (循环/且 ([i (在范围 1 4)]) (> i 0)))

;; 8. 向量/哈希
(定义 v (向量 1 2 3))
(向量-赋值！ v 1 99)
(printf "8. 向量: ~a 哈希: ~a\n"
  (向量->列表 v) (哈希-引用 (哈希 'a 1) 'a))

;; 9. 结构
(结构 point (x y) #:transparent)
(定义 pt (point 3 4))
(printf "9. 结构: x=~a y=~a 结构?=~a 列表=~a\n"
  (point-x pt) (point-y pt) (结构? pt) (结构->列表 pt))

;; 10. 数学子模块
(printf "10. 子模块: pi=~a sinh(1)=~a xor=~a fx+=~a flsin=~a\n"
  圆周率 (双曲正弦 1.0) (异或 #t #f) (定点+ 1 2) (浮点正弦 0.0))

;; 11. 续延
(printf "11. 续延: ~a\n" (续延 (函数 (k) (k 100))))

;; 12. 异常
(定义 exn-result
  (处理异常 ([exn:fail? (函数 (e) "caught")])
    (引发 (错误 "boom"))))
(printf "12. 异常: ~a\n" exn-result)

;; 13. 参数
(定义 pp (制造参数 0))
(参数化 ([pp 77]) (printf "13. 参数: 参数化=~a " pp))
(printf "恢复=~a\n" (pp))

;; 14. 盒/赋值
(定义 bx (盒 10))
(盒赋值！ bx 20)
(printf "14. 盒: ~a\n" (开盒 bx))

;; 15. 多值
(定义多值 (a b) (多值 1 2))
(printf "15. 多值: ~a ~a\n" a b)

;; 16. 类型谓词
(printf "16. 谓词: 对?=~a 空值?=~a 数字?=~a 布尔?=~a\n"
  (对? (对 1 2)) (空值? '()) (数字? 42) (布尔? #f))

;; 17. 文件/路径
(printf "17. 路径: ~a\n" (构建路径 "/tmp" "test"))

;; 18. 自由/绑定标识符等同 (phase-1)
(定义语法 (id-eq stx)
  (语法匹配 stx ()
    [(_ a b)
     (if (自由标识符等同? #'a #'b)
       #'"eq" #'"neq")]))
(printf "18. id: free-id=?=~a\n" (id-eq x x))

(显示 "\n=== 全部测试完成 ===\n")
