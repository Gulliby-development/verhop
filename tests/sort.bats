#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "sortOrdersVersions" {
  row 0 $'1.0.0\n1.2.0\n1.10.0\n2.0.0\n' '' $'sort' $'2.0.0' $'1.0.0' $'1.10.0' $'1.2.0'
  row 0 $'1.0.0-alpha\n1.0.0-alpha.1\n1.0.0-alpha.beta\n1.0.0-beta\n1.0.0-beta.2\n1.0.0-beta.11\n1.0.0-rc.1\n1.0.0\n' '' $'sort' $'1.0.0' $'1.0.0-rc.1' $'1.0.0-alpha' $'1.0.0-alpha.1' $'1.0.0-alpha.beta' $'1.0.0-beta' $'1.0.0-beta.2' $'1.0.0-beta.11'
  row 0 $'2.0.0\n1.5.0\n1.0.0\n' '' $'sort' $'-r' $'1.0.0' $'2.0.0' $'1.5.0'
  row 0 $'1.0.0\n1.0.0-rc.1\n1.0.0-alpha\n' '' $'sort' $'--reverse' $'1.0.0-rc.1' $'1.0.0' $'1.0.0-alpha'
  row 0 $'0.9.0\n1.0.0+b\n1.0.0+a\n1.0.0+c\n' '' $'sort' $'1.0.0+b' $'1.0.0+a' $'0.9.0' $'1.0.0+c'
  row 0 $'1.0.0+b\n1.0.0+a\n1.0.0+c\n0.9.0\n' '' $'sort' $'-r' $'1.0.0+b' $'1.0.0+a' $'0.9.0' $'1.0.0+c'
  row 0 $'1.2.3\n' '' $'sort' $'1.2.3'
  row 2 '' $'verhop: invalid version "bad": bad core\n' $'sort' $'1.0.0' $'bad' $'worse'
  row 0 '' '' $'sort' $'-r'
  row 2 '' $'verhop: invalid version "-r": bad core\n' $'sort' $'-r' $'-r'
  row_in $'1.0.0\n0.9.0\n2.0.0\n' 0 $'0.9.0\n1.0.0\n2.0.0\n' '' $'sort'
  row_in $'1.0.0\n0.9.0\n2.0.0' 0 $'2.0.0\n1.0.0\n0.9.0\n' '' $'sort' $'-r'
  row_in '' 0 '' '' $'sort'
  row_in $'1.0.0\n\n2.0.0\n' 2 '' $'verhop: invalid version "": empty\n' $'sort'
  row_in $'1.0.0\r\n2.0.0\r\n' 2 '' $'verhop: invalid version "1.0.0\r": bad character\n' $'sort'
  row_in $'1.0.0\nignored\n' 0 $'2.0.0\n' '' $'sort' $'2.0.0'
}
