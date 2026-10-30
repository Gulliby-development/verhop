# shellcheck shell=sh

# Check the numeric limits for an identifier already known to contain only digits.
sv__numeric_reason() {
  SN_REASON=
  case $1 in
    *[!0123456789]*)
      return 0
      ;;
  esac
  if [ "${#1}" -gt 18 ]; then
    SN_REASON='number too long'
    return 1
  fi
  if [ "${#1}" -gt 1 ] && [ "${1#0}" != "$1" ]; then
    SN_REASON='leading zero'
    return 1
  fi
  return 0
}

# Validate and report the first SemVer violation without producing output.
sv_reason() {
  SV_REASON=
  SR_INPUT=$1

  if [ -z "$SR_INPUT" ]; then
    SV_REASON=empty
    return 1
  fi
  case $SR_INPUT in
    *[!0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.+-]*)
      SV_REASON='bad character'
      return 1
      ;;
  esac

  SR_MAIN=$SR_INPUT
  SR_BUILD=
  case $SR_INPUT in
    *+*)
      SR_BUILD=${SR_INPUT#*+}
      SR_MAIN=${SR_INPUT%%+*}
      case $SR_BUILD in
        '' | .* | *. | *..* | *+*)
          SV_REASON='bad build'
          return 1
          ;;
      esac
      ;;
  esac

  SR_CORE=$SR_MAIN
  SR_PRE=
  SR_HAS_PRE=0
  case $SR_MAIN in
    *-*)
      SR_HAS_PRE=1
      SR_CORE=${SR_MAIN%%-*}
      SR_PRE=${SR_MAIN#*-}
      ;;
  esac

  case $SR_CORE in
    '' | .* | *. | *..* | *[!0123456789.]*)
      SV_REASON='bad core'
      return 1
      ;;
  esac
  case $SR_CORE in
    *.*.*)
      SR_FIRST=${SR_CORE%%.*}
      SR_REST=${SR_CORE#*.}
      SR_SECOND=${SR_REST%%.*}
      SR_THIRD=${SR_REST#*.}
      case $SR_THIRD in
        *.*)
          SV_REASON='bad core'
          return 1
          ;;
      esac
      ;;
    *)
      SV_REASON='bad core'
      return 1
      ;;
  esac

  for SR_PART in "$SR_FIRST" "$SR_SECOND" "$SR_THIRD"; do
    if ! sv__numeric_reason "$SR_PART"; then
      SV_REASON=$SN_REASON
      return 1
    fi
  done

  if [ "$SR_HAS_PRE" -eq 1 ]; then
    case $SR_PRE in
      '' | .* | *. | *..*)
        SV_REASON='bad prerelease'
        return 1
        ;;
    esac
    SR_REMAIN=$SR_PRE
    while :; do
      SR_IDENT=${SR_REMAIN%%.*}
      if ! sv__numeric_reason "$SR_IDENT"; then
        SV_REASON=$SN_REASON
        return 1
      fi
      case $SR_REMAIN in
        *.*) SR_REMAIN=${SR_REMAIN#*.} ;;
        *) break ;;
      esac
    done
  fi
  return 0
}

# Compare canonical decimal identifiers without shell arithmetic.
sv__cmp_decimal() {
  scd_left=$1
  scd_right=$2
  if [ "${#scd_left}" -lt "${#scd_right}" ]; then
    SCD_RESULT=-1
  elif [ "${#scd_left}" -gt "${#scd_right}" ]; then
    SCD_RESULT=1
  elif [ "$scd_left" = "$scd_right" ]; then
    SCD_RESULT=0
  else
    scd_first=$(printf '%s\n%s\n' "$scd_left" "$scd_right" | sort | sed -n '1p')
    if [ "$scd_first" = "$scd_left" ]; then
      SCD_RESULT=-1
    else
      SCD_RESULT=1
    fi
  fi
}

# Compare validated text identifiers in the caller's C locale.
sv__cmp_text() {
  sct_left=$1
  sct_right=$2
  if [ "$sct_left" = "$sct_right" ]; then
    SCT_RESULT=0
  else
    sct_first=$(printf '%s\n%s\n' "$sct_left" "$sct_right" | sort | sed -n '1p')
    if [ "$sct_first" = "$sct_left" ]; then
      SCT_RESULT=-1
    else
      SCT_RESULT=1
    fi
  fi
}

# Compare two already validated semantic versions without producing output.
sv_cmp() {
  SV_CMP=0
  sc_left=$1
  sc_right=$2

  sc_left_main=${sc_left%%+*}
  sc_right_main=${sc_right%%+*}
  sc_left_core=${sc_left_main%%-*}
  sc_right_core=${sc_right_main%%-*}
  sc_left_pre=
  sc_right_pre=
  sc_left_has_pre=0
  sc_right_has_pre=0
  case $sc_left_main in
    *-*)
      sc_left_has_pre=1
      sc_left_pre=${sc_left_main#*-}
      ;;
  esac
  case $sc_right_main in
    *-*)
      sc_right_has_pre=1
      sc_right_pre=${sc_right_main#*-}
      ;;
  esac

  sc_left_rest=$sc_left_core
  sc_right_rest=$sc_right_core
  while :; do
    sc_left_part=${sc_left_rest%%.*}
    sc_right_part=${sc_right_rest%%.*}
    sv__cmp_decimal "$sc_left_part" "$sc_right_part"
    if [ "$SCD_RESULT" -ne 0 ]; then
      SV_CMP=$SCD_RESULT
      return 0
    fi
    case $sc_left_rest in
      *.*) sc_left_rest=${sc_left_rest#*.} ;;
      *) break ;;
    esac
    sc_right_rest=${sc_right_rest#*.}
  done

  if [ "$sc_left_has_pre" -ne "$sc_right_has_pre" ]; then
    if [ "$sc_left_has_pre" -eq 1 ]; then
      SV_CMP=-1
    else
      SV_CMP=1
    fi
    return 0
  fi
  if [ "$sc_left_has_pre" -eq 0 ]; then
    return 0
  fi

  sc_left_rest=$sc_left_pre
  sc_right_rest=$sc_right_pre
  while :; do
    sc_left_ident=${sc_left_rest%%.*}
    sc_right_ident=${sc_right_rest%%.*}
    case $sc_left_ident in
      *[!0123456789]*) sc_left_numeric=0 ;;
      *) sc_left_numeric=1 ;;
    esac
    case $sc_right_ident in
      *[!0123456789]*) sc_right_numeric=0 ;;
      *) sc_right_numeric=1 ;;
    esac

    if [ "$sc_left_numeric" -eq 1 ] && [ "$sc_right_numeric" -eq 1 ]; then
      sv__cmp_decimal "$sc_left_ident" "$sc_right_ident"
      sc_ident_result=$SCD_RESULT
    elif [ "$sc_left_numeric" -eq 1 ]; then
      sc_ident_result=-1
    elif [ "$sc_right_numeric" -eq 1 ]; then
      sc_ident_result=1
    else
      sv__cmp_text "$sc_left_ident" "$sc_right_ident"
      sc_ident_result=$SCT_RESULT
    fi
    if [ "$sc_ident_result" -ne 0 ]; then
      SV_CMP=$sc_ident_result
      return 0
    fi

    sc_left_more=0
    sc_right_more=0
    case $sc_left_rest in *.*) sc_left_more=1 ;; esac
    case $sc_right_rest in *.*) sc_right_more=1 ;; esac
    if [ "$sc_left_more" -ne "$sc_right_more" ]; then
      if [ "$sc_left_more" -eq 1 ]; then
        SV_CMP=1
      else
        SV_CMP=-1
      fi
      return 0
    fi
    if [ "$sc_left_more" -eq 0 ]; then
      return 0
    fi
    sc_left_rest=${sc_left_rest#*.}
    sc_right_rest=${sc_right_rest#*.}
  done
}

# Increment one validated canonical decimal identifier without overflow.
sv__bump_increment() {
  sbi_value=$1
  SBI_VALUE=
  if [ "$sbi_value" = 999999999999999999 ]; then
    return 1
  fi
  SBI_VALUE=$((sbi_value + 1))
  return 0
}

# Bump a validated version without producing output.
sv_bump() {
  SV_BUMPED=
  sb_part=$1
  sb_version=$2
  sb_main=${sb_version%%+*}
  sb_pre=
  sb_has_pre=0
  case $sb_main in
    *-*)
      sb_has_pre=1
      sb_core=${sb_main%%-*}
      sb_pre=${sb_main#*-}
      ;;
    *) sb_core=$sb_main ;;
  esac

  sb_major=${sb_core%%.*}
  sb_rest=${sb_core#*.}
  sb_minor=${sb_rest%%.*}
  sb_patch=${sb_rest#*.}

  case $sb_part in
    major)
      if ! sv__bump_increment "$sb_major"; then
        return 1
      fi
      sb_result=$SBI_VALUE.0.0
      ;;
    minor)
      if ! sv__bump_increment "$sb_minor"; then
        return 1
      fi
      sb_result=$sb_major.$SBI_VALUE.0
      ;;
    patch)
      if ! sv__bump_increment "$sb_patch"; then
        return 1
      fi
      sb_result=$sb_major.$sb_minor.$SBI_VALUE
      ;;
    pre)
      if [ "$sb_has_pre" -eq 0 ]; then
        if ! sv__bump_increment "$sb_patch"; then
          return 1
        fi
        sb_result=$sb_major.$sb_minor.$SBI_VALUE-rc.0
      else
        case $sb_pre in
          *.*)
            sb_before_last=${sb_pre%.*}
            sb_last=${sb_pre##*.}
            ;;
          *)
            sb_before_last=
            sb_last=$sb_pre
            ;;
        esac
        case $sb_last in
          *[!0123456789]*)
            sb_result=$sb_core-$sb_pre.0
            ;;
          *)
            if ! sv__bump_increment "$sb_last"; then
              return 1
            fi
            if [ -n "$sb_before_last" ]; then
              sb_result=$sb_core-$sb_before_last.$SBI_VALUE
            else
              sb_result=$sb_core-$SBI_VALUE
            fi
            ;;
        esac
      fi
      ;;
    *) return 1 ;;
  esac

  SV_BUMPED=$sb_result
  return 0
}
