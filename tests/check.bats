#!/usr/bin/env bats

# shellcheck source=helper.bash
source "${BATS_TEST_DIRNAME}/helper.bash"

@test "checkReportsEveryVersion" {
  row 0 $'1.2.3 ok\n' $'' $'check' $'1.2.3'
  row 0 $'0.0.0 ok\n10.20.30 ok\n123456789012345678.0.0 ok\n' $'' $'check' $'0.0.0' $'10.20.30' $'123456789012345678.0.0'
  row 0 $'1.0.0-alpha.1 ok\n1.0.0-0.3.7 ok\n1.0.0-x.7.z.92 ok\n1.0.0-x-y-z.-- ok\n' $'' $'check' $'1.0.0-alpha.1' $'1.0.0-0.3.7' $'1.0.0-x.7.z.92' $'1.0.0-x-y-z.--'
  row 0 $'1.0.0+build.5 ok\n1.0.0-rc.1+20130313144700 ok\n1.0.0+0001 ok\n1.0.0-beta+exp.sha.5114f85 ok\n' $'' $'check' $'1.0.0+build.5' $'1.0.0-rc.1+20130313144700' $'1.0.0+0001' $'1.0.0-beta+exp.sha.5114f85'
  row 1 $' invalid: empty\n' $'' $'check' $''
  row 1 $'1.2 invalid: bad core\n1.2.3.4 invalid: bad core\n1..3 invalid: bad core\na.b.c invalid: bad core\n1.2.3. invalid: bad core\n.1.2.3 invalid: bad core\n1.2.x invalid: bad core\n- invalid: bad core\n1-2-3 invalid: bad core\n' $'' $'check' $'1.2' $'1.2.3.4' $'1..3' $'a.b.c' $'1.2.3.' $'.1.2.3' $'1.2.x' $'-' $'1-2-3'
  row 1 $'01.2.3 invalid: leading zero\n1.02.3 invalid: leading zero\n1.2.03 invalid: leading zero\n00.0.0 invalid: leading zero\n' $'' $'check' $'01.2.3' $'1.02.3' $'1.2.03' $'00.0.0'
  row 1 $'1.2.3-01 invalid: leading zero\n1.2.3-a.01.b invalid: leading zero\n1.2.3-00 invalid: leading zero\n1.2.3-0a ok\n1.2.3-0 ok\n' $'' $'check' $'1.2.3-01' $'1.2.3-a.01.b' $'1.2.3-00' $'1.2.3-0a' $'1.2.3-0'
  row 1 $'1.2.3- invalid: bad prerelease\n1.2.3-.a invalid: bad prerelease\n1.2.3-a. invalid: bad prerelease\n1.2.3-a..b invalid: bad prerelease\n' $'' $'check' $'1.2.3-' $'1.2.3-.a' $'1.2.3-a.' $'1.2.3-a..b'
  row 1 $'1.2.3+ invalid: bad build\n1.2.3+.a invalid: bad build\n1.2.3+a. invalid: bad build\n1.2.3+a..b invalid: bad build\n1.2.3+a+b invalid: bad build\n+ invalid: bad build\n1.2.3-+ invalid: bad build\n' $'' $'check' $'1.2.3+' $'1.2.3+.a' $'1.2.3+a.' $'1.2.3+a..b' $'1.2.3+a+b' $'+' $'1.2.3-+'
  row 1 $'v1.2.3 invalid: bad core\n1.2.3  invalid: bad character\n1_2_3 invalid: bad character\n1.2.3-\xc3\xa9 invalid: bad character\n1.2.3\n invalid: bad character\n\xd9\xa1.0.0 invalid: bad character\n' $'' $'check' $'v1.2.3' $'1.2.3 ' $'1_2_3' $'1.2.3-\xc3\xa9' $'1.2.3\n' $'\xd9\xa1.0.0'
  row 1 $'1234567890123456789.0.0 invalid: number too long\n1.2.3-1234567890123456789 invalid: number too long\n1.2.3-123456789012345678 ok\n0.0.1234567890123456789 invalid: number too long\n' $'' $'check' $'1234567890123456789.0.0' $'1.2.3-1234567890123456789' $'1.2.3-123456789012345678' $'0.0.1234567890123456789'
  row 1 $'01.2.3-a..b invalid: leading zero\n1.2-a..b invalid: bad core\n1.2.3-a..b+ invalid: bad build\n1.2.3-01+a..b invalid: bad build\n1234567890123456789.01.0 invalid: number too long\n1.2.3-x.1234567890123456789.01 invalid: number too long\n' $'' $'check' $'01.2.3-a..b' $'1.2-a..b' $'1.2.3-a..b+' $'1.2.3-01+a..b' $'1234567890123456789.01.0' $'1.2.3-x.1234567890123456789.01'
  row 2 $'' $'verhop: check needs at least one VERSION\n' $'check'
  row 1 $'1.0.0 ok\nx invalid: bad core\n2.0.0 ok\n1.0 invalid: bad core\n' $'' $'check' $'1.0.0' $'x' $'2.0.0' $'1.0'
}
