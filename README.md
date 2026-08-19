# action-m2-coding-standards

Runs static analysis tools against Magento 2 code as separately
gateable GitHub Actions jobs. Supports PHPCS and PHPStan; PHPMD is
pending the shared L3 ruleset (magic42/ansible#512) and fails with an
explicit error if selected.

This is a composite action (v2+). The v1.x Docker image is gone: PHPCS
runs on the runner, and PHPStan runs the project's own
`vendor/bin/phpstan` so the committed config, extensions and
autoloader all match local runs.

## Usage

Call the action once per tool, as separate jobs, so each check passes
or fails independently and downstream jobs can gate on them
(`needs: [phpstan]` etc.):

```yaml
jobs:
  phpcs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: bcmath,gd,intl,pdo_mysql,soap,xsl,zip,sockets
          coverage: none
      - name: Composer install
        env:
          COMPOSER_AUTH: ${{ secrets.AUTH_JSON }}
        run: composer install --prefer-dist --no-progress --no-interaction
      - uses: magic42/action-m2-coding-standards@v2.0.0
        with:
          tool: phpcs
          use_project_tools: 'true'
          phpcs_warning_severity: '0'

  phpstan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: bcmath,gd,intl,pdo_mysql,soap,xsl,zip,sockets
          coverage: none
      - name: Composer install
        env:
          COMPOSER_AUTH: ${{ secrets.AUTH_JSON }}
        run: composer install --prefer-dist --no-progress --no-interaction
      - uses: magic42/action-m2-coding-standards@v2.0.0
        with:
          tool: phpstan
```

## Inputs

| Input | Default | Notes |
|---|---|---|
| `tool` | `phpcs` | `phpcs`, `phpstan` or `phpmd` (phpmd errors until #512). |
| `php_version` | `8.3` | PHP for the bundled phpcs toolchain (legacy mode). |
| `phpcs_standard` | none | Ruleset path or installed standard. Empty = `Magento2` (legacy) or the committed `phpcs.xml.dist` (project mode). |
| `phpcs_report` | `checkstyle` | Feeds the bundled problem matcher. |
| `phpcs_severity` | `8` (legacy only) | Project mode defers to the committed ruleset. |
| `phpcs_warning_severity` | none | Set to `0` to gate on errors only (L1 baseline approach). |
| `phpcs_path` | `app/code/Magic42` (legacy only) | Project mode defers to the committed ruleset. |
| `phpcs_extensions` | `php` (legacy only) | Project mode defers to the committed ruleset. |
| `use_project_tools` | `false` | phpcs only: use `vendor/bin/phpcs` + committed `phpcs.xml.dist`. Requires composer install first. |
| `phpstan_config` | `phpstan.neon` | Committed config; it owns the analysis scope (no paths are passed). |
| `phpstan_error_format` | `github` | `github` = native PR annotations. `checkstyle` uses the bundled matcher instead. |
| `phpstan_memory_limit` | `-1` | |

## Modes

### PHPCS legacy mode (default, v1.x compatible)

With no inputs, behaviour matches v1.1.0 exactly: the
`magento/magento-coding-standard` and `phpcompatibility` packages are
installed globally on the runner and phpcs runs with the `Magento2`
standard, severity 8, checkstyle report, against `app/code/Magic42`.
No composer install of the project is needed. Deprecated: prefer
project mode once the repo commits a `phpcs.xml.dist`.

### PHPCS project mode (`use_project_tools: 'true'`)

Runs the project's `vendor/bin/phpcs`, which auto-discovers the
committed `phpcs.xml.dist` (ruleset, paths, severities). No rules live
in this action. Requires `composer install` first.

### PHPStan (project mode only)

Runs the project's `vendor/bin/phpstan` against the committed config
(default `phpstan.neon`), which should include the shared magic42
config from `magic42/magento-dev-tools` plus the project's committed
`phpstan-baseline.neon`. Requires `composer install` first.

Note: the default `github` error format bypasses custom error
formatters such as Magento's `FilteredErrorFormatter` (analysis is
identical; only output filtering differs). If CI reports errors that
local filtered runs hide, fold them into the baseline or set
`phpstan_error_format: checkstyle`.

## Migrating from v1.x

- No changes needed for a bare `uses:` bump: default behaviour is
  unchanged (phpcs, Magento2, severity 8, checkstyle,
  `app/code/Magic42`), now on PHP 8.3 instead of 7.4.
- The action is composite, so there is no Docker image build; jobs
  start faster.
- The previously undeclared `phpcs_extensions` input is now declared.
- To adopt PHPStan, add a second job with `tool: phpstan` plus a
  composer install step, and commit `phpstan.neon` +
  `phpstan-baseline.neon` to the project.
