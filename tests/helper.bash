# Shared by every .bats file: `load helper`.

VERHOP="${BATS_TEST_DIRNAME}/../bin/verhop"

# row EXIT OUT ERR ARGS...: runs verhop with ARGS and no standard input, then compares the exit status,
# the standard output and the standard error byte for byte.
row() {
  row_in '' "$@"
}

# row_in STDIN EXIT OUT ERR ARGS...: the same, with STDIN as the standard input.
row_in() {
  local stdin=$1 want_exit=$2 want_out=$3 want_err=$4 got_exit=0
  shift 4
  printf '%s' "$stdin" | sh "$VERHOP" "$@" >"$BATS_TEST_TMPDIR/out" 2>"$BATS_TEST_TMPDIR/err" || got_exit=$?
  printf '%s' "$want_out" >"$BATS_TEST_TMPDIR/want_out"
  printf '%s' "$want_err" >"$BATS_TEST_TMPDIR/want_err"
  if [ "$got_exit" -ne "$want_exit" ]; then
    echo "exit status $got_exit, want $want_exit" >&2
    return 1
  fi
  cmp "$BATS_TEST_TMPDIR/out" "$BATS_TEST_TMPDIR/want_out" || return 1
  cmp "$BATS_TEST_TMPDIR/err" "$BATS_TEST_TMPDIR/want_err" || return 1
}
