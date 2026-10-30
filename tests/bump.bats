#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "bumpRaisesOnePart" {
  row 0 $'2.0.0\n' '' $'bump' $'major' $'1.2.3'
  row 0 $'1.3.0\n' '' $'bump' $'minor' $'1.2.3'
  row 0 $'1.2.4\n' '' $'bump' $'patch' $'1.2.3'
  row 0 $'2.0.0\n' '' $'bump' $'major' $'1.2.3-rc.1+build.7'
  row 0 $'1.2.4\n' '' $'bump' $'patch' $'1.2.3-rc.1'
  row 0 $'1.2.4-rc.0\n' '' $'bump' $'pre' $'1.2.3'
  row 0 $'1.2.4-rc.0\n' '' $'bump' $'pre' $'1.2.3+build'
  row 0 $'1.2.3-rc.2\n' '' $'bump' $'pre' $'1.2.3-rc.1'
  row 0 $'1.2.3-rc.10\n' '' $'bump' $'pre' $'1.2.3-rc.9+b'
  row 0 $'1.2.3-beta.0\n' '' $'bump' $'pre' $'1.2.3-beta'
  row 0 $'1.2.3-8\n' '' $'bump' $'pre' $'1.2.3-7'
  row 0 $'1.2.3-x-1.0\n' '' $'bump' $'pre' $'1.2.3-x-1'
  row 2 '' $'verhop: bump would overflow "1.2.999999999999999999"\n' $'bump' $'patch' $'1.2.999999999999999999'
  row 2 '' $'verhop: bump would overflow "1.2.999999999999999999"\n' $'bump' $'pre' $'1.2.999999999999999999'
  row 2 '' $'verhop: bump would overflow "1.2.3-999999999999999999"\n' $'bump' $'pre' $'1.2.3-999999999999999999'
  row 2 '' $'verhop: bump would overflow "999999999999999999.0.0"\n' $'bump' $'major' $'999999999999999999.0.0'
  row 2 '' $'verhop: unknown part "other"\n' $'bump' $'other' $'1.2.3'
  row 2 '' $'verhop: bump needs a part and a version\n' $'bump' $'major'
  row 2 '' $'verhop: bump needs a part and a version\n' $'bump' $'major' $'1.2.3' $'extra'
  row 2 '' $'verhop: invalid version "1.2": bad core\n' $'bump' $'major' $'1.2'
}
