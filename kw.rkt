#lang racket/base
(require (for-syntax racket/base))

(provide 定义-关键字函数)

(define-syntax (定义-关键字函数 stx)
  (syntax-case stx ()
    [(_ 中文名 英文名 . 声明列表)
     (let ([中文函数名 (syntax-e #'中文名)]
           [英文函数名 (syntax-e #'英文名)])
       (define 声明解析
         (for/list ([s (in-list (syntax->list #'声明列表))])
           (let ([d (syntax->list s)])
             (list (syntax-e (car d))
                   (syntax-e (cadr d))
                   (for/list ([v (in-list (cddr d))])
                     (let ([p (syntax->list v)])
                       (cons (syntax-e (car p))
                             (syntax-e (cadr p)))))))))
       (define kw-map (map (lambda (x) (cons (car x) (cadr x))) 声明解析))
       (define val-map (map (lambda (x) (cons (cadr x) (caddr x))) 声明解析))
       (datum->syntax
         stx
         `(define-syntax (, 中文函数名 stx2)
            (syntax-case stx2 ()
              [(_ arg ...)
               (let* ([lst (syntax->list #'(arg ...))]
                      [translated
                       (let loop ([rest lst] [k #f] [acc '()])
                         (cond
                           [(null? rest) (reverse acc)]
                           [else
                            (let ([d (syntax->datum (car rest))])
                              (cond
                                [(keyword? d)
                                 (let lookup ([m ',kw-map])
                                   (cond
                                     [(null? m)
                                      (loop (cdr rest) d
                                            (cons (datum->syntax (car rest) d (car rest)) acc))]
                                     [(eq? d (caar m))
                                      (loop (cdr rest) (cdar m)
                                            (cons (datum->syntax (car rest) (cdar m) (car rest)) acc))]
                                     [else (lookup (cdr m))]))]
                                [(and k (pair? d) (eq? (car d) 'quote)
                                      (pair? (cdr d)) (symbol? (cadr d)))
                                 (let vlookup ([m ',val-map])
                                   (cond
                                     [(null? m)
                                      (loop (cdr rest) #f (cons (car rest) acc))]
                                     [(eq? k (caar m))
                                      (let ([tbl (cdar m)])
                                        (let pairloop ([p tbl])
                                          (cond
                                            [(null? p)
                                             (loop (cdr rest) #f (cons (car rest) acc))]
                                            [(eq? (cadr d) (caar p))
                                             (loop (cdr rest) #f
                                                   (cons (datum->syntax (car rest)
                                                           (list 'quote (cdar p))
                                                           (car rest))
                                                         acc))]
                                            [else (pairloop (cdr p))])))]
                                     [else (vlookup (cdr m))]))]
                                [else
                                 (loop (cdr rest) #f (cons (car rest) acc))]))]))])
                 (datum->syntax stx2
                   (cons ', 英文函数名 (map syntax-e translated))
                   stx2))]))
         stx))]))
