## Parse command line arguments into an aarray.
## Data types docs: <https://github.com/hernancerm/zgold/blob/main/DEVELOP.md>.
##
## ~ Example:
##   ---
##   Call:
##     parse_args \
##       '--i-am-a-bool-opt' \
##       '[--i-have-a-default]=wood' \
##       --spanish hola y 'a b' --english=hello -m v1 -n=v2 --i-am-a-bool-opt
##   ---
##   Expected parsing:
##     typeset -A args=(
##       [--english]=hello
##       [--i-am-a-bool-opt]=true
##       [--i-have-a-default]=wood
##       [--spanish]=hola
##       [-m]=v2
##       [-n]=v1
##       [positional]="typeset -a args_pos=(y 'a b')"
##     )
##   ---
##
## ~ Not supported:
##   * Merging of short-form options, e.g., -G -s == -Gs.
##
## ~ Usage:
##   The usage in the 'Call' section above can be set in a script as below:
##   ---
##     # <Source 'args.zsh'>.
##     # Build `args` aarray using the parse_args function.
##     eval "$(parse_args \
##       '--i-am-a-bool-opt' \
##       '[--i-have-a-default]=wood' \
##       ${@})"
##   ---
##   The user would call their script like this:
##   ---
##     ./<my-script> --spanish hola y 'a b' --english hello --i-am-a-bool-opt
##   ---
##
## @param $1:ciarray Boolean options.
## @param $2:caarray Options which have a default.
## @param $3... User-provided args, usually the script args.
## @stdout:aarray Parsed args as `args`.
function parse_args {
  local -A args=()
  local -a args_pos=()
  eval "local -a bool_opts=(${1})"
  eval "local -A defaults=(${2})"
  local -a user_args=(${@[@]:3})
  local skip_parse_of_current_arg='false'
  for (( i=1 ; i<=${#user_args} ; i++ )); do
    if [[ "${skip_parse_of_current_arg}" = 'true' ]]; then
      skip_parse_of_current_arg='false'
      continue
    fi
    # If arg begins with a dash (-) then it's an option.
    if [[ "${${user_args[${i}]}[1]}" = '-' ]]; then
      if [[ ${bool_opts[(i)${user_args[i]}]} -le ${#bool_opts} ]]; then
        # The option is a bool(ean).
        args+=(["${user_args[${i}]}"]='true')
      else
        # The option accepts a value.
        if [[ "${${user_args[${i}]}[(i)=]}" -lt ${#user_args[${i}]} ]]; then
          # The option name and value are separated by an equal symbol (=).
          local opt_equal_symbol_lhs="${${(s:=:)${user_args[${i}]}}[1]}"
          local opt_equal_symbol_rhs="${${(s:=:)${user_args[${i}]}}[2]}"
          args+=(["${opt_equal_symbol_lhs}"]="${opt_equal_symbol_rhs}")
        else
          # The option name and value are separated by whitespace.
          args+=(["${user_args[${i}]}"]="${user_args[$((i+1))]}")
          skip_parse_of_current_arg='true'
        fi
      fi
      continue
    fi
    # Otherwise, it's a positional arg.
    args_pos+=("${user_args[$((i))]}")
  done
  # Serialize positional args as an iarray.
  args[positional]="$(typeset -p args_pos)"
  # Assign default values to unset options.
  for flag_name flag_value in ${(kv)defaults}; do
    if [[ -z "${args[${flag_name}]}" ]]; then
      args+=([${flag_name}]=${flag_value})
    fi
  done
  typeset -p args
}
