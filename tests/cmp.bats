#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "cmpComparesPrecedence" {
  row 0 $'0\n' '' $'cmp' $'1.0.0' $'1.0.0'
  row 0 $'-1\n' '' $'cmp' $'2.0.0' $'10.0.0'
  row 0 $'-1\n' '' $'cmp' $'1.9.0' $'1.10.0'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-alpha' $'1.0.0'
  row 0 $'1\n' '' $'cmp' $'1.0.0' $'1.0.0-rc.1'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-alpha' $'1.0.0-alpha.1'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-alpha.1' $'1.0.0-alpha.beta'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-beta.2' $'1.0.0-beta.11'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-9' $'1.0.0-a'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-Z' $'1.0.0-a'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-a-b' $'1.0.0-a0'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-1e3' $'1.0.0-2e1'
  row 0 $'1\n' '' $'cmp' $'1.0.0--2' $'1.0.0--10'
  row 0 $'-1\n' '' $'cmp' $'1.0.0-0x10' $'1.0.0-0x9'
  row 0 $'0\n' '' $'cmp' $'1.0.0+a' $'1.0.0+b'
  row 0 $'0\n' '' $'cmp' $'1.0.0-rc.1+x' $'1.0.0-rc.1'
  row 0 $'1\n' '' $'cmp' $'999999999999999999.0.0' $'999999999999999998.9.9'
  row 2 '' $'verhop: cmp needs exactly two versions\n' $'cmp' $'1.2.3'
  row 2 '' $'verhop: invalid version "1.2": bad core\n' $'cmp' $'1.2.3' $'1.2'
  row 2 '' $'verhop: invalid version "x.y": bad core\n' $'cmp' $'x.y' $'1.2.bad'
}
