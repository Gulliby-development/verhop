# shellcheck shell=sh

verhop_usage() {
  printf '%s\n' \
    'usage: verhop check VERSION...' \
    '       verhop cmp VERSION VERSION' \
    '       verhop bump major|minor|patch|pre VERSION' \
    '       verhop sort [-r] [VERSION...]' \
    '       verhop latest [VERSION...]'
}

verhop_cmd_check() {
  if [ "$#" -eq 0 ]; then
    printf '%s\n' 'verhop: check needs at least one VERSION' >&2
    return 2
  fi

  vc_status=0
  while [ "$#" -gt 0 ]; do
    vc_version=$1
    if sv_reason "$vc_version"; then
      printf '%s ok\n' "$vc_version"
    else
      printf '%s invalid: %s\n' "$vc_version" "$SV_REASON"
      vc_status=1
    fi
    shift
  done
  return "$vc_status"
}

verhop_cmd_cmp() {
  if [ "$#" -ne 2 ]; then
    printf '%s\n' 'verhop: cmp needs exactly two versions' >&2
    return 2
  fi

  vcc_first=$1
  vcc_second=$2
  if ! sv_reason "$vcc_first"; then
    printf 'verhop: invalid version "%s": %s\n' "$vcc_first" "$SV_REASON" >&2
    return 2
  fi
  if ! sv_reason "$vcc_second"; then
    printf 'verhop: invalid version "%s": %s\n' "$vcc_second" "$SV_REASON" >&2
    return 2
  fi

  sv_cmp "$vcc_first" "$vcc_second"
  printf '%s\n' "$SV_CMP"
  return 0
}

verhop_cmd_bump() {
  if [ "$#" -ne 2 ]; then
    printf '%s\n' 'verhop: bump needs a part and a version' >&2
    return 2
  fi

  vcb_part=$1
  vcb_version=$2
  case $vcb_part in
    major | minor | patch | pre) ;;
    *)
      printf 'verhop: unknown part "%s"\n' "$vcb_part" >&2
      return 2
      ;;
  esac

  if ! sv_reason "$vcb_version"; then
    printf 'verhop: invalid version "%s": %s\n' "$vcb_version" "$SV_REASON" >&2
    return 2
  fi
  if ! sv_bump "$vcb_part" "$vcb_version"; then
    printf 'verhop: bump would overflow "%s"\n' "$vcb_version" >&2
    return 2
  fi

  printf '%s\n' "$SV_BUMPED"
  return 0
}

verhop_cmd_sort() {
  vs_reverse=0
  vs_version=
  vs_items=
  vs_sorted=
  vs_nl='
'

  if [ "$#" -gt 0 ]; then
    case $1 in
      -r | --reverse)
        vs_reverse=1
        shift
        ;;
    esac
  fi

  if [ "$#" -gt 0 ]; then
    while [ "$#" -gt 0 ]; do
      vs_version=$1
      if ! sv_reason "$vs_version"; then
        printf 'verhop: invalid version "%s": %s\n' "$vs_version" "$SV_REASON" >&2
        return 2
      fi
      vs_items=$vs_items$vs_version$vs_nl
      shift
    done
  else
    while IFS= read -r vs_version || [ -n "$vs_version" ]; do
      if ! sv_reason "$vs_version"; then
        printf 'verhop: invalid version "%s": %s\n' "$vs_version" "$SV_REASON" >&2
        return 2
      fi
      vs_items=$vs_items$vs_version$vs_nl
      vs_version=
    done
  fi

  while [ -n "$vs_items" ]; do
    vs_key=${vs_items%%"$vs_nl"*}
    vs_items=${vs_items#*"$vs_nl"}
    vs_rest=$vs_sorted
    vs_before=
    vs_inserted=0
    while [ -n "$vs_rest" ]; do
      vs_prev=${vs_rest%%"$vs_nl"*}
      vs_rest=${vs_rest#*"$vs_nl"}
      sv_cmp "$vs_key" "$vs_prev"
      if { [ "$vs_reverse" -eq 0 ] && [ "$SV_CMP" -lt 0 ]; } ||
        { [ "$vs_reverse" -eq 1 ] && [ "$SV_CMP" -gt 0 ]; }; then
        vs_sorted=$vs_before$vs_key$vs_nl$vs_prev$vs_nl$vs_rest
        vs_inserted=1
        break
      fi
      vs_before=$vs_before$vs_prev$vs_nl
    done
    if [ "$vs_inserted" -eq 0 ]; then
      vs_sorted=$vs_before$vs_key$vs_nl
    fi
  done

  while [ -n "$vs_sorted" ]; do
    vs_output=${vs_sorted%%"$vs_nl"*}
    vs_sorted=${vs_sorted#*"$vs_nl"}
    printf '%s\n' "$vs_output"
  done
  return 0
}

verhop_cmd_latest() {
  vl_best=
  vl_count=0
  vl_version=

  if [ "$#" -gt 0 ]; then
    while [ "$#" -gt 0 ]; do
      vl_version=$1
      if ! sv_reason "$vl_version"; then
        printf 'verhop: invalid version "%s": %s\n' "$vl_version" "$SV_REASON" >&2
        return 2
      fi
      if [ "$vl_count" -eq 0 ]; then
        vl_best=$vl_version
      else
        sv_cmp "$vl_version" "$vl_best"
        if [ "$SV_CMP" -gt 0 ]; then
          vl_best=$vl_version
        fi
      fi
      vl_count=$((vl_count + 1))
      shift
    done
  else
    while IFS= read -r vl_version || [ -n "$vl_version" ]; do
      if ! sv_reason "$vl_version"; then
        printf 'verhop: invalid version "%s": %s\n' "$vl_version" "$SV_REASON" >&2
        return 2
      fi
      if [ "$vl_count" -eq 0 ]; then
        vl_best=$vl_version
      else
        sv_cmp "$vl_version" "$vl_best"
        if [ "$SV_CMP" -gt 0 ]; then
          vl_best=$vl_version
        fi
      fi
      vl_count=$((vl_count + 1))
      vl_version=
    done
  fi

  if [ "$vl_count" -eq 0 ]; then
    printf '%s\n' 'verhop: latest found no versions' >&2
    return 2
  fi
  printf '%s\n' "$vl_best"
  return 0
}

verhop_main() {
  if [ "$#" -eq 0 ]; then
    verhop_usage >&2
    return 2
  fi

  vm_command=$1
  case $vm_command in
    help | -h | --help)
      verhop_usage
      return 0
      ;;
    --version)
      printf '%s\n' 'verhop 0.1.0'
      return 0
      ;;
    check)
      shift
      verhop_cmd_check "$@"
      return $?
      ;;
    cmp)
      shift
      verhop_cmd_cmp "$@"
      return $?
      ;;
    bump)
      shift
      verhop_cmd_bump "$@"
      return $?
      ;;
    sort)
      shift
      verhop_cmd_sort "$@"
      return $?
      ;;
    latest)
      shift
      verhop_cmd_latest "$@"
      return $?
      ;;
    *)
      printf 'verhop: unknown command %s\n' "$vm_command" >&2
      return 2
      ;;
  esac
}
