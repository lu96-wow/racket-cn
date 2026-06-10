#lang racket/base

;; ============================================================
;; rename-macro.rkt — 用简洁数据生成 rename-out 绑定的宏
;;
;; 用法：
;;   (require racket/xxx "rename-macro.rkt")
;;   (rename-define
;;     [原名 中文名1 中文名2 ...]   ;; 第一个是英文原名，剩下的是中文别名
;;     ...)
;;
;; 展开为：
;;   (provide
;;     (rename-out
;;       [原名 中文名1]
;;       [原名 中文名2]
;;       ...))
;;
;; 用 map + quasisyntax 在编译期展平子句，
;; 再用 with-syntax 将结果注入模板，全程保持词法上下文。
;; ============================================================

(require (for-syntax racket/base))

(provide rename-define)

(define-syntax (rename-define stx)
  (syntax-case stx ()
    [(_ [eng cn ...] ...)
     ;; 在编译期把 [eng c1 c2 ...] 展平成 ([eng c1] [eng c2] ...)
     ;; 每个 [eng cn] 对都用 #' 模板生成，保留词法上下文
     (let ([pairs
            (apply append
                   (map (lambda (e-stx cn-stxs)
                          (map (lambda (c-stx)
                                 ;; 用 quasisyntax 保持上下文
                                 #`[#,e-stx #,c-stx])
                               (syntax->list cn-stxs)))
                        (syntax->list #'(eng ...))
                        (syntax->list #'((cn ...) ...))))])
       (with-syntax ([(rename-pair ...) pairs])
         #'(provide
             (rename-out rename-pair ...))))]))
