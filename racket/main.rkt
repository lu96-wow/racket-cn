#lang racket/base

;; ============================================================
;; racket-cn/racket — (require racket-cn/racket) 入口
;;
;; 对应 Racket 的 racket/main.rkt，提供 racket 子模块的所有中文别名。
;; ============================================================

(require "base-impl.rkt"
         "class.rkt"
         "contract.rkt"
         "date.rkt"
         "dict.rkt"
         "file.rkt"
         "function.rkt"
         "future.rkt"
         "generator.rkt"
         "hash.rkt"
         "list.rkt"
         "match.rkt"
         "path.rkt"
         "port.rkt"
         "pretty.rkt"
         "random.rkt"
         "sequence.rkt"
         "set.rkt"
         "splicing.rkt"
         "stream.rkt"
         "string.rkt"
         "system.rkt"
         "trace.rkt"
         "vector.rkt")

(provide (all-from-out "base-impl.rkt")
         (all-from-out "class.rkt")
         (all-from-out "contract.rkt")
         (all-from-out "date.rkt")
         (all-from-out "dict.rkt")
         (all-from-out "file.rkt")
         (all-from-out "function.rkt")
         (all-from-out "future.rkt")
         (all-from-out "generator.rkt")
         (all-from-out "hash.rkt")
         (all-from-out "list.rkt")
         (all-from-out "match.rkt")
         (all-from-out "path.rkt")
         (all-from-out "port.rkt")
         (all-from-out "pretty.rkt")
         (all-from-out "random.rkt")
         (all-from-out "sequence.rkt")
         (all-from-out "set.rkt")
         (all-from-out "splicing.rkt")
         (all-from-out "stream.rkt")
         (all-from-out "string.rkt")
         (all-from-out "system.rkt")
         (all-from-out "trace.rkt")
         (all-from-out "vector.rkt")
          (all-from-out "math.rkt")
          (all-from-out "struct.rkt")
          (all-from-out "bool.rkt")
          (all-from-out "bytes.rkt")
          (all-from-out "format.rkt")
          (all-from-out "symbol.rkt")
          (all-from-out "keyword.rkt")
          (all-from-out "exn.rkt")
          (all-from-out "cmdline.rkt")
          (all-from-out "tcp.rkt")
          (all-from-out "udp.rkt")
          (all-from-out "async-channel.rkt")
          (all-from-out "syntax.rkt")
          (all-from-out "control.rkt")
          (all-from-out "engine.rkt")
          (all-from-out "case.rkt")
          (all-from-out "block.rkt")
          (all-from-out "lazy-require.rkt")
          (all-from-out "include.rkt")
          (all-from-out "os.rkt")
          (all-from-out "prefab.rkt")
          (all-from-out "serialize.rkt")
          (all-from-out "treelist.rkt"
          "unit.rkt"
          "trait.rkt"
          "generic.rkt"
          "fixnum.rkt"
          "flonum.rkt"
          "mutability.rkt"
          "promise.rkt"
          "hash-code.rkt"
          "deprecation.rkt"
          "syntax-srcloc.rkt"
          "repl.rkt"
          "shared.rkt"
          "undefined.rkt"
          "unreachable.rkt"
          "runtime-path.rkt"
          "keyword-transform.rkt"
          "struct-info.rkt"
          "place.rkt"
          "logging.rkt"
          "mutable-treelist.rkt"
          "serialize-structs.rkt"
          "help.rkt"))
