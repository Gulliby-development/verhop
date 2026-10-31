#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "latestPrintsTheHighestPrecedence" {
  row 0 $'2.0.0\n' '' $'latest' $'1.0.0' $'2.0.0' $'1.5.0'
  row 0 $'2.0.0\n' '' $'latest' $'2.0.0'
  row 0 $'1.0.0-beta\n' '' $'latest' $'1.0.0-alpha' $'1.0.0-beta'
  row 0 $'1.0.0\n' '' $'latest' $'1.0.0-rc.1' $'1.0.0'
  row 0 $'1.0.0+b\n' '' $'latest' $'1.0.0+b' $'1.0.0+a'
  row 0 $'1.0.0+a\n' '' $'latest' $'1.0.0+a' $'1.0.0+b' $'0.9.0'
  row 0 $'1.10.0\n' '' $'latest' $'1.2.0' $'1.10.0' $'1.9.0'
  row 0 $'1.0.0-alpha.beta\n' '' $'latest' $'1.0.0-alpha.1' $'1.0.0-alpha.beta' $'1.0.0-alpha'
  row 0 $'1.0.0-beta.11\n' '' $'latest' $'1.0.0-beta.2' $'1.0.0-beta.11'
  row 0 $'999999999999999999.0.0\n' '' $'latest' $'999999999999999999.0.0' $'1.0.0'
  row_in $'1.0.0\n2.1.0\n2.0.0\n' 0 $'2.1.0\n' '' $'latest'
  row_in $'1.0.0\n1.0.0+x' 0 $'1.0.0\n' '' $'latest'
  row_in $'9.9.9\n' 0 $'1.0.0\n' '' $'latest' $'1.0.0'
  row 2 '' $'verhop: invalid version "bad": bad core\n' $'latest' $'1.0.0' $'bad' $'worse'
  row 2 '' $'verhop: invalid version "-r": bad core\n' $'latest' $'-r'
  row 2 '' $'verhop: invalid version "": empty\n' $'latest' $''
  row_in '' 2 '' $'verhop: latest found no versions\n' $'latest'
  row_in $'1.0.0\n\n2.0.0\n' 2 '' $'verhop: invalid version "": empty\n' $'latest'
  row_in $'1.0.0\r\n' 2 '' $'verhop: invalid version "1.0.0\r": bad character\n' $'latest'
}
