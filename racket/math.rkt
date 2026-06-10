#lang racket/base
(require racket/math)
(require "../rename-macro.rkt")

(rename-define
  [pi 圆周率]
  [pi.f 单精度圆周率]
  [nan? 非数?]
  [infinite? 无穷?]
  [positive-integer? 正整数?]
  [negative-integer? 负整数?]
  [nonpositive-integer? 非正整数?]
  [nonnegative-integer? 非负整数?]
  [natural? 自然数?]
  [sqr 平方]
  [sgn 符号]
  [conjugate 共轭]
  [sinh 双曲正弦]
  [cosh 双曲余弦]
  [tanh 双曲正切]
  [degrees->radians 角度->弧度]
  [radians->degrees 弧度->角度]
  [exact-round 精确四舍五入]
  [exact-floor 精确向下取整]
  [exact-ceiling 精确向上取整]
  [exact-truncate 精确截断]
  [order-of-magnitude 数量级]
)
