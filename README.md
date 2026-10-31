<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# verhop

verhop is a small, offline, deterministic POSIX-shell command-line tool for
checking, comparing, bumping, and sorting Semantic Versioning 2.0.0 versions.
It is intended for release scripts and CI jobs that need predictable version
handling without network access or non-POSIX runtime utilities. See the
[MIT license](LICENSE).

[![CI](https://github.com/Gulliby-development/verhop/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/verhop/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Install and run

Clone the repository, then run the script from the checkout:

```sh
git clone https://github.com/Gulliby-development/verhop.git
cd verhop
sh bin/verhop --help
```

The script and its libraries remain in the `bin/` and `lib/` layout.
Runtime requires only `sh` and POSIX utilities. Linux, macOS, and Windows
users running Git Bash can use the same commands; on Windows, use Git Bash
rather than the native command prompt. No installation step, network access,
or runtime package is required.

## Commands

Synopsis:

```text
usage: verhop check VERSION...
       verhop cmp VERSION VERSION
       verhop bump major|minor|patch|pre VERSION
       verhop sort [-r] [VERSION...]
       verhop latest [VERSION...]
```

### Check

Check reports every argument in order as `VERSION ok` or
`VERSION invalid: REASON`. It exits 0 if all versions are valid, 1 if any
are invalid, and 2 if no version was supplied. The empty argument is printed
as a leading space before `invalid: empty`.

```console
$ sh bin/verhop check 1.2.3
1.2.3 ok
```

### Compare

`cmp A B` prints `-1`, `0`, or `1` for precedence and exits 0. It checks the
argument count first; if the count is not exactly two, it reports
`verhop: cmp needs exactly two versions` without validating any versions. With
two arguments, it validates A and then B, reporting only the first invalid
version in argument order as `verhop: invalid version "ARG": REASON`. Either
argument error exits 2 and writes a diagnostic to standard error.

```console
$ sh bin/verhop cmp 1.0.0-alpha 1.0.0
-1
```

### Bump

`bump PART VERSION` prints the bumped version. Parts are `major`, `minor`,
`patch`, and `pre`; successful calls exit 0. Argument errors and overflow
exit 2 and write a diagnostic to standard error.

```console
$ sh bin/verhop bump pre 1.2.3
1.2.4-rc.0
```

### Sort

`sort` sorts arguments in ascending precedence; an initial `-r` or
`--reverse` selects descending order. With no versions, it reads lines from
standard input. It exits 0 on success and 2 for the first invalid input; no
sorted output is emitted unless all inputs validate.

```console
$ sh bin/verhop sort 2.0.0 1.0.0
1.0.0
2.0.0
```

When arguments are supplied, stdin is not read. Only the first argument may
select reverse mode; a later `-r` is treated as a version. Input order is
validated before sorting. Duplicates are retained, and equal-precedence
versions (including versions differing only in BUILD) retain their original
relative order in both ascending and reverse modes. An empty input stream
succeeds silently. A final line without LF is processed; blank lines are
invalid, and CR bytes are retained and therefore make a version invalid.

### Latest

`latest [VERSION...]` prints the version with the highest precedence, as it
was written. With no arguments it reads versions from standard input, one per
line, under the same line rules as `sort`. Every input is validated first, in
order, and the first invalid one is reported as
`verhop: invalid version "ARG": REASON` with exit status 2 and no output. Among
versions of equal precedence (for example versions that differ only in BUILD)
the first one wins. No versions at all, which means no arguments and an empty
input stream, is `verhop: latest found no versions` with exit status 2. Only
`latest` itself is a command word: an argument such as `-r` is a version and
is invalid.

```console
$ sh bin/verhop latest 1.9.0 1.10.0 1.10.0-rc.1
1.10.0
```

## Version grammar and precedence

A version has the form `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`. There is no
`v` prefix, whitespace, or leading/trailing dot. The first `+` begins BUILD;
the first `-` before it begins PRERELEASE. Hyphens inside prerelease or build
identifiers are part of those identifiers.

MAJOR, MINOR, and PATCH are decimal numbers of 1–18 digits, with no leading
zero except for `0`. PRERELEASE consists of dot-separated, nonempty
identifiers containing only ASCII letters, digits, or hyphens. A numeric
prerelease identifier is 1–18 digits and has no leading zero; other identifiers
are text (for example, `0a`, `01a`, `-`, and `a-b`). BUILD consists of
dot-separated, nonempty identifiers using the same ASCII character set; it
allows leading zeros and has no length limit.

Precedence compares MAJOR, MINOR, and PATCH numerically. For the same core,
a prerelease is lower than a release. Prerelease identifiers are compared
left-to-right: numeric identifiers compare by numeric value, numeric sorts
before text, and text compares by ASCII byte order (`-`, digits, `A-Z`,
then `a-z`). If common identifiers match, the prerelease with fewer
identifiers sorts first. BUILD is ignored for precedence.

Bumping `major` increments MAJOR and resets MINOR and PATCH to zero;
`minor` increments MINOR and resets PATCH to zero; `patch` increments
PATCH. These three discard prerelease and BUILD. For `pre`, a version with a
prerelease increments its final numeric identifier, or appends `.0` if its
last identifier is text. A version without prerelease increments PATCH and
becomes `-rc.0`. Bumping always removes BUILD. An increment that would exceed
`999999999999999999` reports overflow.

## Validation reasons and errors

A version is assigned exactly the first applicable reason in this order:

1. `empty`: the string is empty.
2. `bad character`: it contains anything outside ASCII `0-9`, `A-Z`,
   `a-z`, dot, plus, and hyphen.
3. `bad build`: after the first plus, BUILD is empty, starts or ends with a
   dot, contains consecutive dots, or contains another plus.
4. `bad core`: the portion before the first prerelease hyphen is not exactly
   three nonempty decimal groups separated by single dots.
5. For MAJOR, MINOR, PATCH from left to right: `number too long` if the
   current group exceeds 18 digits, otherwise `leading zero` if it has a
   leading zero. The first failing group decides.
6. `bad prerelease`: prerelease is empty, starts or ends with a dot, or
   contains consecutive dots.
7. For numeric prerelease identifiers from left to right: `number too long`
   if the current identifier exceeds 18 digits, otherwise `leading zero`.
   The first failing identifier decides.

Thus earlier rules take priority: for example, a core leading zero is reported
before malformed prerelease, while malformed BUILD is reported before core
errors.

Errors are one line on standard error with no standard output and exit status
2. Exact command diagnostics are:

- No command: the four-line usage synopsis above.
- Unknown first word: `verhop: unknown command WORD`.
- `check` without versions: `verhop: check needs at least one VERSION`.
- `cmp` with other than two arguments:
  `verhop: cmp needs exactly two versions`.
- `bump` with other than two arguments:
  `verhop: bump needs a part and a version`; then an unsupported part:
  `verhop: unknown part "PART"`; then an invalid version:
  `verhop: invalid version "ARG": REASON`.
- `cmp`, `sort` and `latest` invalid versions:
  `verhop: invalid version "ARG": REASON`.
- `latest` with no versions: `verhop: latest found no versions`.
- Bump overflow: `verhop: bump would overflow "ARG"`.

`check` is the exception to the error-stream rule: it prints one result per
input to standard output and returns 1 if at least one is invalid. Its
no-argument error returns 2. `help`, `-h`, and `--help` print usage to
standard output and exit 0, ignoring trailing arguments. `--version` prints
`verhop 0.1.0` and exits 0, also ignoring trailing arguments. With no
arguments, usage goes to standard error and exits 2.

## Development

The source layout is `bin/verhop` (entry point), `lib/semver.sh` (version
validation and semantic operations), `lib/commands.sh` (CLI commands), and
`tests/` (Bats tests). The shell implementation uses POSIX `sh` and POSIX
utilities so it can run on Linux, macOS, and Windows Git Bash. Development
tools are not runtime dependencies.

Run the checks from the repository root:

```sh
shellcheck bin/verhop lib/semver.sh lib/commands.sh tests/helper.bash
shfmt -d .
bats tests
```

Install Bats using one of these development-only options:

```sh
npm install -g bats
```

On macOS, use `brew install bats-core`; on Linux or another supported system,
the system package manager's Bats package is also suitable. ShellCheck,
shfmt, and Bats are needed only to work on or test the project, not to run
verhop.

## License

MIT, see [LICENSE](LICENSE).

---

Built with BAKED
