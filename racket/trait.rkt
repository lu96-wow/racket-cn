#lang racket/base
(require racket/trait)

(provide
 (rename-out
   [trait 特征]
   [trait? 特征?]
   [trait-sum 特征和]
   [trait->mixin 特征->混入]
   [trait-rename 特征重命名]
   [trait-rename-field 特征重命名字段]))
