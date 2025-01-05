## Parse command line arguments into an associative array.
##
## ~ Example:
##   ---
##   Call:
##     parse_args \
##       '--i-am-a-bool-opt' \
##       '[--i-have-a-default]=wood' \
##       --spanish hola y 'a b' --english hello --i-am-a-bool-opt
##   ---
##   Expected parsing:
##     typeset -A args=(
##       [--i-am-a-bool-opt]=true
##       [--english]=hello
##       [--spanish]=hola
##       [--i-have-a-default]=wood
##       [positional]="typeset -a args_pos=(y 'a b')"
##     )
##   ---
##
## ~ Not supported:
##   * Using an equal symbol (=) to separate the option name to its value.
##   * Merging of short-form options, e.g., -G -s == -Gs.
##
## ~ Usage:
##   The usage in the 'Call' section above can be set in a script as below:
##   ---
##     # <Source 'args.zsh'>.
##     # Build `args` aarray using the parse_args function.
##     eval "$(parse_args \
##       '--i-am-a-bool-opt' \
##       "[--i-have-a-default]=wood" \
##       ${@})"
##   ---
##   The user would call their script like this:
##   ---
##     ./<my-script> --spanish hola y x --english hello --i-am-a-bool-opt
##   ---
##
## @param $1:ciarray Boolean options.
## @param $2:caarray Options which have a default.
## @param $3... Arguments provided by the user.
## @stdout Pretty-printed associative array definition of parsed args, `args`.
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
      # Check if the option is bool(ean).
      if [[ ${bool_opts[(i)${user_args[i]}]} -le ${#bool_opts} ]]; then
        args+=(["${user_args[${i}]}"]='true')
      else
        args+=(["${user_args[${i}]}"]="${user_args[$((i+1))]}")
        skip_parse_of_current_arg='true'
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
  # Print aarray.
  typeset -p args
}
