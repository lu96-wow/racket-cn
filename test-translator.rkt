#lang racket/base
(require rackunit "translator.rkt" racket/string racket/list)

(define (翻译代码 code #:方向 [方向 '英->中])
  (翻译字符串 code #:方向 方向))
(define (翻译后包含? code pattern #:方向 [方向 '英->中])
  (string-contains? (翻译代码 code #:方向 方向) pattern))

(printf "\n===== racket-cn 翻译器测试 =====\n\n")

;; ============ 核心特殊形式 ============
(check-true (翻译后包含? "(define x 1)" "定义") "define -> 定义")
(check-true (翻译后包含? "(lambda x 1)" "函数") "lambda -> 函数")
(check-true (翻译后包含? "(if x 1)" "如果") "if -> 如果")
(check-true (翻译后包含? "(cond x 1)" "条件") "cond -> 条件")
(check-true (翻译后包含? "(let x 1)" "令") "let -> 令")
(check-true (翻译后包含? "(set! x 1)" "赋值！") "set! -> 赋值！")
(check-true (翻译后包含? "(begin x 1)" "顺序求值") "begin -> 顺序求值")
(check-true (翻译后包含? "(when x 1)" "当") "when -> 当")
(check-true (翻译后包含? "(unless x 1)" "除非") "unless -> 除非")
(check-true (翻译后包含? "(and x 1)" "且") "and -> 且")
(check-true (翻译后包含? "(or x 1)" "或") "or -> 或")
(check-true (翻译后包含? "(not x 1)" "非") "not -> 非")
(check-true (翻译后包含? "(quote x 1)" "引述") "quote -> 引述")

;; ============ 列表 ============
(check-true (翻译后包含? "(cons 1 2)" "对") "cons -> 对")
(check-true (翻译后包含? "(car 1 2)" "首") "car -> 首")
(check-true (翻译后包含? "(cdr 1 2)" "尾") "cdr -> 尾")
(check-true (翻译后包含? "(null? 1 2)" "空值?") "null? -> 空值?")
(check-true (翻译后包含? "(list 1 2)" "列表") "list -> 列表")
(check-true (翻译后包含? "(map 1 2)" "映射") "map -> 映射")
(check-true (翻译后包含? "(filter 1 2)" "过滤") "filter -> 过滤")

;; ============ IO ============
(check-true (翻译后包含? "(display x)" "显示") "display -> 显示")
(check-true (翻译后包含? "(displayln x)" "显示行") "displayln -> 显示行")
(check-true (翻译后包含? "(printf x)" "格式化输出") "printf -> 格式化输出")
(check-true (翻译后包含? "(write x)" "写出") "write -> 写出")
(check-true (翻译后包含? "(read x)" "读取") "read -> 读取")

;; ============ 中->英 ============
(check-true (翻译后包含? "(定义 x 1)" "define" #:方向 '中->英) "定义 -> define")
(check-true (翻译后包含? "(函数 x 1)" "lambda" #:方向 '中->英) "函数 -> lambda")
(check-true (翻译后包含? "(如果 x 1)" "if" #:方向 '中->英) "如果 -> if")
(check-true (翻译后包含? "(条件 x 1)" "cond" #:方向 '中->英) "条件 -> cond")
(check-true (翻译后包含? "(令 x 1)" "let" #:方向 '中->英) "令 -> let")
(check-true (翻译后包含? "(当 x 1)" "when" #:方向 '中->英) "当 -> when")
(check-true (翻译后包含? "(且 x 1)" "and" #:方向 '中->英) "且 -> and")
(check-true (翻译后包含? "(或 x 1)" "or" #:方向 '中->英) "或 -> or")
(check-true (翻译后包含? "(非 x 1)" "not" #:方向 '中->英) "非 -> not")

;; ============ 关键字翻译 ============
(check-true (翻译后包含? "(open-output-file \"a\" #:exists 'truncate)" "#:如果存在") "#:exists -> #:如果存在")
(check-true (翻译后包含? "(打开输出文件 \"a\" #:如果存在 '截断)" "#:exists" #:方向 '中->英) "#:如果存在 -> #:exists")
(check-true (翻译后包含? "(open-output-file \"a\" #:exists 'truncate)" "截断") "'truncate -> '截断")

;; ============ 子模块抽样 ============
(check-true (翻译后包含? "(hash-empty? x)" "哈希-空?") "hash-empty?")
(check-true (翻译后包含? "(hash-union x)" "哈希-并集") "hash-union")
(check-true (翻译后包含? "(take x)" "取前") "take")
(check-true (翻译后包含? "(drop x)" "去掉前") "drop")
(check-true (翻译后包含? "(sort x)" "排序") "sort")
(check-true (翻译后包含? "(range x)" "范围") "range")
(check-true (翻译后包含? "(first x)" "第一个") "first")
(check-true (翻译后包含? "(last x)" "最后一个") "last")
(check-true (翻译后包含? "(match x)" "匹配") "match")
(check-true (翻译后包含? "(class x)" "类") "class")
(check-true (翻译后包含? "(new x)" "新建") "new")
(check-true (翻译后包含? "(set x)" "集合") "set")
(check-true (翻译后包含? "(for/list x)" "循环/列表") "for/list")
(check-true (翻译后包含? "(for/and x)" "循环/且") "for/and")
(check-true (翻译后包含? "(for/fold x)" "循环/折叠") "for/fold")
(check-true (翻译后包含? "(in-range x)" "在范围") "in-range")
(check-true (翻译后包含? "(in-list x)" "在列表") "in-list")
(check-true (翻译后包含? "(循环/列表 ([x (在范围 3)]) x)" "for/list" #:方向 '中->英) "循环/列表 -> for/list")

;; ============ 嵌套/边界 ============
(let ([r (翻译代码 "(let ([x (let ([y 1]) y)]) (let ([z 2]) (+ x z)))" #:方向 '英->中)])
  (check-true (string-contains? r "令") "嵌套let: 令"))
(let ([r (翻译代码 "(hash (no-translate (quote hash)) (quote a))" #:方向 '英->中)])
  (check-true (string-contains? r "(quote hash)") "no-translate: 'hash保留")
  (check-true (string-contains? r "(引述 a)") "no-translate: 'a仍翻译"))
(check-equal? (翻译代码 "()" #:方向 '英->中) "()\n" "空列表")
(check-equal? (翻译代码 "()" #:方向 '中->英) "()\n" "空列表中->英")

(printf "\n全部测试完成!\n")
