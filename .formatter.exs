# Used by "mix format"
[
  line_length: 80,
  inputs: ["mix.exs", "{config,lib,test}/**.{ex,exs}"],
  locals_without_parens: [
    # General
    throw: :*,
    inject_error: :*,
    # Component DSL
    spit: :*,
    throw: :*,
    error: :*,
    effect: :*,
    fields: :*,
    state: :*,
    component: :*,
    state_change: :*,
    external_effect: :*,
    # Logger
    info: :*,
    debug: :*,
    warn: :*,
    error: :*
  ]
]
