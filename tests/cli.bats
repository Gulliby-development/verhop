#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "dispatchesTheCommandLine" {
  row 2 $'' $'usage: verhop check VERSION...\n       verhop cmp VERSION VERSION\n       verhop bump major|minor|patch|pre VERSION\n       verhop sort [-r] [VERSION...]\n       verhop latest [VERSION...]\n'
  row 0 $'usage: verhop check VERSION...\n       verhop cmp VERSION VERSION\n       verhop bump major|minor|patch|pre VERSION\n       verhop sort [-r] [VERSION...]\n       verhop latest [VERSION...]\n' $'' $'help'
  row 0 $'usage: verhop check VERSION...\n       verhop cmp VERSION VERSION\n       verhop bump major|minor|patch|pre VERSION\n       verhop sort [-r] [VERSION...]\n       verhop latest [VERSION...]\n' $'' $'-h'
  row 0 $'usage: verhop check VERSION...\n       verhop cmp VERSION VERSION\n       verhop bump major|minor|patch|pre VERSION\n       verhop sort [-r] [VERSION...]\n       verhop latest [VERSION...]\n' $'' $'--help'
  row 0 $'usage: verhop check VERSION...\n       verhop cmp VERSION VERSION\n       verhop bump major|minor|patch|pre VERSION\n       verhop sort [-r] [VERSION...]\n       verhop latest [VERSION...]\n' $'' $'help' $'check'
  row 0 $'verhop 0.1.0\n' $'' $'--version'
  row 0 $'verhop 0.1.0\n' $'' $'--version' $'x'
  row 2 $'' $'verhop: unknown command frob\n' $'frob'
  row 2 $'' $'verhop: unknown command -r\n' $'-r'
  row 2 $'' $'verhop: unknown command Check\n' $'Check' $'1.0.0'
  row 2 $'' $'verhop: unknown command \n' $''
}
