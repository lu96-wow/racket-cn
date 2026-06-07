;; backward compatibility: delegate to racket-cn/base's reader submodule
(module reader '#%kernel
  (#%require (submod racket-cn/base reader))
  (#%provide (all-from (submod racket-cn/base reader))))
