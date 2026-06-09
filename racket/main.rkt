#lang racket/base

;; ============================================================
;; racket-cn/racket — (require racket-cn/racket) 入口
;;
;; 对应 Racket 的 racket/main.rkt，提供 racket 子模块的所有中文别名。
;; ============================================================

(require
  "async-channel.rkt"
  "base-impl.rkt"
  "block.rkt"
  "bool.rkt"
  "bytes.rkt"
  "case.rkt"
  "class.rkt"
  "cmdline.rkt"
  "contract.rkt"
  "control.rkt"
  "date.rkt"
  "deprecation.rkt"
  "dict.rkt"
  "engine.rkt"
  "enter.rkt"
  "exn.rkt"
  "extflonum.rkt"
  "fasl.rkt"
  "file.rkt"
  "fixnum.rkt"
  "flonum.rkt"
  "format.rkt"
  "function.rkt"
  "future.rkt"
  "generator.rkt"
  "generic.rkt"
  "hash-code.rkt"
  "hash.rkt"
  "help.rkt"
  "include.rkt"
  "interaction-info.rkt"
  "keyword-transform.rkt"
  "keyword.rkt"
  "language-info.rkt"
  "lazy-require.rkt"
  "list.rkt"
  "local.rkt"
  "logging.rkt"
  "match.rkt"
  "math.rkt"
  "mutability.rkt"
  "mutable-treelist.rkt"
  "os.rkt"
  "path.rkt"
  "performance-hint.rkt"
  "place.rkt"
  "port.rkt"
  "prefab.rkt"
  "pretty.rkt"
  "promise.rkt"
  "random.rkt"
  "repl.rkt"
  "rerequire.rkt"
  "runtime-config.rkt"
  "runtime-path.rkt"
  "sequence.rkt"
  "serialize-structs.rkt"
  "serialize.rkt"
  "set.rkt"
  "shared.rkt"
  "splicing.rkt"
  "stream.rkt"
  "string.rkt"
  "struct-info.rkt"
  "struct.rkt"
  "stxparam.rkt"
  "surrogate.rkt"
  "symbol.rkt"
  "syntax-srcloc.rkt"
  "syntax.rkt"
  "system.rkt"
  "tcp.rkt"
  "trace.rkt"
  "trait.rkt"
  "treelist.rkt"
  "udp.rkt"
  "undefined.rkt"
  "unit.rkt"
  "unreachable.rkt"
  "vector.rkt")

(provide (all-from-out "async-channel.rkt")
         (all-from-out "base-impl.rkt")
         (all-from-out "block.rkt")
         (all-from-out "bool.rkt")
         (all-from-out "bytes.rkt")
         (all-from-out "case.rkt")
         (all-from-out "class.rkt")
         (all-from-out "cmdline.rkt")
         (all-from-out "contract.rkt")
         (all-from-out "control.rkt")
         (all-from-out "date.rkt")
         (all-from-out "deprecation.rkt")
         (all-from-out "dict.rkt")
         (all-from-out "engine.rkt")
         (all-from-out "enter.rkt")
         (all-from-out "exn.rkt")
         (all-from-out "extflonum.rkt")
         (all-from-out "fasl.rkt")
         (all-from-out "file.rkt")
         (all-from-out "fixnum.rkt")
         (all-from-out "flonum.rkt")
         (all-from-out "format.rkt")
         (all-from-out "function.rkt")
         (all-from-out "future.rkt")
         (all-from-out "generator.rkt")
         (all-from-out "generic.rkt")
         (all-from-out "hash-code.rkt")
         (all-from-out "hash.rkt")
         (all-from-out "help.rkt")
         (all-from-out "include.rkt")
         (all-from-out "interaction-info.rkt")
         (all-from-out "keyword-transform.rkt")
         (all-from-out "keyword.rkt")
         (all-from-out "language-info.rkt")
         (all-from-out "lazy-require.rkt")
         (all-from-out "list.rkt")
         (all-from-out "local.rkt")
         (all-from-out "logging.rkt")
         (all-from-out "match.rkt")
         (all-from-out "math.rkt")
         (all-from-out "mutability.rkt")
         (all-from-out "mutable-treelist.rkt")
         (all-from-out "os.rkt")
         (all-from-out "path.rkt")
         (all-from-out "performance-hint.rkt")
         (all-from-out "place.rkt")
         (all-from-out "port.rkt")
         (all-from-out "prefab.rkt")
         (all-from-out "pretty.rkt")
         (all-from-out "promise.rkt")
         (all-from-out "random.rkt")
         (all-from-out "repl.rkt")
         (all-from-out "rerequire.rkt")
         (all-from-out "runtime-config.rkt")
         (all-from-out "runtime-path.rkt")
         (all-from-out "sequence.rkt")
         (all-from-out "serialize-structs.rkt")
         (all-from-out "serialize.rkt")
         (all-from-out "set.rkt")
         (all-from-out "shared.rkt")
         (all-from-out "splicing.rkt")
         (all-from-out "stream.rkt")
         (all-from-out "string.rkt")
         (all-from-out "struct-info.rkt")
         (all-from-out "struct.rkt")
         (all-from-out "stxparam.rkt")
         (all-from-out "surrogate.rkt")
         (all-from-out "symbol.rkt")
         (all-from-out "syntax-srcloc.rkt")
         (all-from-out "syntax.rkt")
         (all-from-out "system.rkt")
         (all-from-out "tcp.rkt")
         (all-from-out "trace.rkt")
         (all-from-out "trait.rkt")
         (all-from-out "treelist.rkt")
         (all-from-out "udp.rkt")
         (all-from-out "undefined.rkt")
         (all-from-out "unit.rkt")
         (all-from-out "unreachable.rkt")
         (all-from-out "vector.rkt"))
