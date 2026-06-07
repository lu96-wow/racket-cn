#lang racket/base
(require rackunit "translator.rkt" racket/string racket/list)

(define (翻译代码 code #:方向 [方向 '英->中])
  (翻译字符串 code #:方向 方向))
(define (翻译后包含? code pattern #:方向 [方向 '英->中])
  (string-contains? (翻译代码 code #:方向 方向) pattern))

(printf "\n===== racket-cn 翻译器测试 =====\n\n")

;; ============ 英->中: 特殊形式 ============
(check-true (翻译后包含? "(define x 1)" "定义")      "define -> 定义")
(check-true (翻译后包含? "(lambda (x) x)" "函数")     "lambda -> 函数")
(check-true (翻译后包含? "(if #t 1 0)" "如果")        "if -> 如果")
(check-true (翻译后包含? "(cond [a 1] [else 2])" "条件") "cond -> 条件")
(check-true (翻译后包含? "(let ([x 1]) x)" "令")     "let -> 令")
(check-true (翻译后包含? "(set! x 2)" "赋值！")       "set! -> 赋值！")
(check-true (翻译后包含? "(begin 1 2)" "顺序求值")   "begin -> 顺序求值")
(check-true (翻译后包含? "(when #t 1)" "当")          "when -> 当")
(check-true (翻译后包含? "(unless #f 1)" "除非")      "unless -> 除非")
(check-true (翻译后包含? "(and #t #f)" "且")           "and -> 且")
(check-true (翻译后包含? "(or #t #f)" "或")            "or -> 或")
(check-true (翻译后包含? "(not #t)" "非")              "not -> 非")
(check-true (翻译后包含? "(quote x)" "引述")           "quote -> 引述")

;; ============ 英->中: 列表 ============
(check-true (翻译后包含? "(cons 1 2)" "对")     "cons -> 对")
(check-true (翻译后包含? "(car x)" "首")        "car -> 首")
(check-true (翻译后包含? "(cdr x)" "尾")        "cdr -> 尾")
(check-true (翻译后包含? "(null? x)" "空值?")   "null? -> 空值?")
(check-true (翻译后包含? "(list 1 2 3)" "列表") "list -> 列表")
(check-true (翻译后包含? "(map f lst)" "映射")  "map -> 映射")
(check-true (翻译后包含? "(filter f lst)" "过滤") "filter -> 过滤")

;; ============ 英->中: IO ============
(check-true (翻译后包含? "(display x)" "显示")        "display -> 显示")
(check-true (翻译后包含? "(displayln x)" "显示行")    "displayln -> 显示行")
(check-true (翻译后包含? "(printf \"hi\")" "格式化输出") "printf -> 格式化输出")
(check-true (翻译后包含? "(write x)" "写出")          "write -> 写出")
(check-true (翻译后包含? "(read)" "读取")             "read -> 读取")

;; ============ 英->中: 数学 ============
(check-true (翻译后包含? "(abs -5)" "绝对值")   "abs -> 绝对值")
(check-true (翻译后包含? "(add1 5)" "加1")      "add1 -> 加1")
(check-true (翻译后包含? "(sqrt 4)" "平方根")   "sqrt -> 平方根")
(check-true (翻译后包含? "(even? 2)" "偶数?")   "even? -> 偶数?")
(check-true (翻译后包含? "(number? 42)" "数字?") "number? -> 数字?")

;; ============ 中->英: 特殊形式 ============
(check-true (翻译后包含? "(定义 x 1)" "define" #:方向 '中->英)              "定义 -> define")
(check-true (翻译后包含? "(函数 (x) x)" "lambda" #:方向 '中->英)             "函数 -> lambda")
(check-true (翻译后包含? "(如果 #t 1 0)" "if" #:方向 '中->英)                "如果 -> if")
(check-true (翻译后包含? "(条件 [a 1] [否则 2])" "cond" #:方向 '中->英)      "条件 -> cond")
(check-true (翻译后包含? "(令 ([x 1]) x)" "let" #:方向 '中->英)              "令 -> let")
(check-true (翻译后包含? "(当 #t 1)" "when" #:方向 '中->英)                  "当 -> when")
(check-true (翻译后包含? "(且 #t #f)" "and" #:方向 '中->英)                  "且 -> and")
(check-true (翻译后包含? "(或 #t #f)" "or" #:方向 '中->英)                   "或 -> or")
(check-true (翻译后包含? "(非 #t)" "not" #:方向 '中->英)                     "非 -> not")

;; ============ 中->英: 列表 ============
(check-true (翻译后包含? "(对 1 2)" "cons" #:方向 '中->英)       "对 -> cons")
(check-true (翻译后包含? "(首 x)" "car" #:方向 '中->英)           "首 -> car")
(check-true (翻译后包含? "(尾 x)" "cdr" #:方向 '中->英)           "尾 -> cdr")
(check-true (翻译后包含? "(空值? x)" "null?" #:方向 '中->英)     "空值? -> null?")
(check-true (翻译后包含? "(列表 1 2 3)" "list" #:方向 '中->英)   "列表 -> list")
(check-true (翻译后包含? "(映射 f lst)" "map" #:方向 '中->英)    "映射 -> map")

;; ============ 关键字翻译 ============
(check-true (翻译后包含? "(open-output-file \"a\" #:exists 'truncate)" "#:如果存在")
            "#:exists -> #:如果存在")
(check-true (翻译后包含? "(打开输出文件 \"a\" #:如果存在 '截断)" "#:exists" #:方向 '中->英)
            "#:如果存在 -> #:exists")
(check-true (翻译后包含? "(open-output-file \"a\" #:exists 'truncate)" "截断")
            "'truncate -> '截断")
(check-true (翻译后包含? "(open-output-file \"a\" #:exists 'replace)" "替换")
            "'replace -> '替换")
(check-true (翻译后包含? "(open-output-file \"a\" #:mode 'text)" "文本")
            "'text -> '文本")
(check-true (翻译后包含? "(打开输出文件 \"a\" #:如果存在 '截断)" "truncate" #:方向 '中->英)
            "'截断 -> 'truncate")
(check-true (翻译后包含? "(打开输出文件 \"a\" #:模式 '文本)" "text" #:方向 '中->英)
            "'文本 -> 'text")

;; 关键字值混用: 中文关键字 + 英文值
(let ([r (翻译代码 "(打开输出文件 \"a\" #:如果存在 'truncate)" #:方向 '中->英)])
  (check-true (string-contains? r "#:exists") "混用: kw翻译")
  (check-true (string-contains? r "truncate") "混用: val翻译"))

;; ============ 嵌套结构 ============
(let ([r (翻译代码 "(let ([x (let ([y 1]) y)]) (let ([z 2]) (+ x z)))" #:方向 '英->中)])
  (check-true (string-contains? r "令") "嵌套let: 令")
  (check-true (string-contains? r "+")   "嵌套let: +"))

(let ([r (翻译代码 "(cond [(even? x) (displayln \"even\")] [else (displayln \"odd\")])" #:方向 '英->中)])
  (check-true (string-contains? r "条件")   "嵌套cond: 条件")
  (check-true (string-contains? r "偶数?")  "嵌套cond: 偶数?")
  (check-true (string-contains? r "显示行") "嵌套cond: 显示行")
  (check-true (string-contains? r "否则")   "嵌套cond: 否则"))

;; ============ 用户定义名称不被翻译 ============
(let ([r (翻译代码 "(define (my-func x) (* x x))" #:方向 '英->中)])
  (check-true (string-contains? r "定义")     "用户: 定义")
  (check-true (string-contains? r "my-func")  "用户: my-func不变")
  (check-false (string-contains? r "我的函数") "用户: 无伪造翻译"))

(let ([r (翻译代码 "(定义 (我的函数 x) (* x x))" #:方向 '中->英)])
  (check-true (string-contains? r "define")      "用户中: define")
  (check-true (string-contains? r "我的函数")    "用户中: 我的函数不变")
  (check-false (string-contains? r "my-function") "用户中: 无伪造翻译"))

;; ============ 字面量不被破坏 ============
(let ([r (翻译代码 "(displayln \"Hello, define lambda if!\")" #:方向 '英->中)])
  (check-true (string-contains? r "显示行") "字面量: 显示行")
  (check-true (string-contains? r "\"Hello, define lambda if!\"") "字面量: 字符串不变"))

(let ([r (翻译代码 "(list 42 3.14 #t #f)" #:方向 '英->中)])
  (check-true (string-contains? r "列表") "字面量: 列表")
  (check-true (string-contains? r "42")   "字面量: 42")
  (check-true (string-contains? r "#t")   "字面量: #t")
  (check-true (string-contains? r "#f")   "字面量: #f"))

;; ============ quote ============
;; 注意: 语法翻译器会遍历 quote 内部并翻译标识符（这是语法层面翻译的特性）
(let ([r (翻译代码 "(quote (define lambda if))" #:方向 '英->中)])
  (check-true (string-contains? r "引述") "quote: 引述")
  (check-true (string-contains? r "定义") "quote内: define->定义")
  (check-true (string-contains? r "函数") "quote内: lambda->函数")
  (check-true (string-contains? r "如果") "quote内: if->如果"))

;; ============ 四舍五入 ============
;; write 把 'x 输出为 (quote x), 把 [x] 输出为 (x), 语义等价
(let* ([orig "(define (add1* x) (add1 x))"]
       [back (翻译代码 (翻译代码 orig #:方向 '英->中) #:方向 '中->英)])
  (check-true (string-contains? back "define") "四舍五入: 简单"))

(let* ([orig "(open-output-file \"a\" #:exists 'truncate)"]
       [back (翻译代码 (翻译代码 orig #:方向 '英->中) #:方向 '中->英)])
  (check-true (string-contains? back "#:exists") "四舍五入: 关键字"))

(let* ([orig "(let ([x (if (even? n) 0 1)]) (displayln x))"]
       [back (翻译代码 (翻译代码 orig #:方向 '英->中) #:方向 '中->英)])
  (check-true (string-contains? back "displayln") "四舍五入: 嵌套"))

;; ============ 子模块 ============
(check-true (翻译后包含? "(hash-empty? h)" "哈希-空?")         "hash-empty?")
(check-true (翻译后包含? "(hash-union a b)" "哈希-并集")      "hash-union")
(check-true (翻译后包含? "(take lst 5)" "取前")               "take")
(check-true (翻译后包含? "(drop lst 3)" "去掉前")             "drop")
(check-true (翻译后包含? "(sort lst <)" "排序")               "sort")
(check-true (翻译后包含? "(range 10)" "范围")                 "range")
(check-true (翻译后包含? "(first lst)" "第一个")              "first")
(check-true (翻译后包含? "(last lst)" "最后一个")             "last")
(check-true (翻译后包含? "(vector-empty? v)" "向量-空?")      "vector-empty?")
(check-true (翻译后包含? "(match x [1 'a])" "匹配")           "match")
(check-true (翻译后包含? "(class object% (super-new))" "类")   "class")
(check-true (翻译后包含? "(new obj%)" "新建")                 "new")
(check-true (翻译后包含? "(set 1 2 3)" "集合")               "set")

;; ============ for 系列 ============
(check-true (翻译后包含? "(for/list ([x (in-range 3)]) x)" "循环/列表") "for/list")
(check-true (翻译后包含? "(for/and ([x (in-range 3)]) x)" "循环/且")   "for/and")
(check-true (翻译后包含? "(for/fold ([s 0]) ([x (in-range 3)]) (+ s x))" "循环/折叠") "for/fold")
(check-true (翻译后包含? "(in-range 5)" "在范围")  "in-range")
(check-true (翻译后包含? "(in-list lst)" "在列表") "in-list")
(check-true (翻译后包含? "(循环/列表 ([x (在范围 3)]) x)" "for/list" #:方向 '中->英)
            "循环/列表 -> for/list")

;; ============ 边界情况 ============
(check-equal? (翻译代码 "()" #:方向 '英->中) "()\n" "空列表")
(check-equal? (翻译代码 "()" #:方向 '中->英) "()\n" "空列表中->英")

(let ([r (翻译代码 "(define-syntax (my-or stx) (syntax-case stx () [(_ x) #'x]))" #:方向 '英->中)])
  (check-true (string-contains? r "定义语法") "定义语法")
  (check-true (string-contains? r "语法匹配") "语法匹配"))

(check-true (翻译后包含? "(normalize-path p)" "规范化路径") "normalize-path")
(check-true (翻译后包含? "(system-type)" "系统-类型")       "system-type")

(printf "\n全部测试完成!\n")
