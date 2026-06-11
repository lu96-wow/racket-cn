#lang racket/base
(require racket/trait)
(require "../rename-macro.rkt")

(rename-define
  [trait 特征]
  [trait? 特征?]
  [trait-sum 特征-和]
  [trait->mixin 特征->混入]
  [trait-rename 特征-重命名]
  [trait-rename-field 特征-重命名-字段]
)
