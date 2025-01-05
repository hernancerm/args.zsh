. "./args.zsh"
resources='test/golden'

typeset -A test_cases=(
  [smoke]="parse_args \
    '--i-am-a-bool-opt' \
    '[--i-have-a-default]=wood' \
    --spanish hola y 'a b' --english hello --i-am-a-bool-opt"
)
