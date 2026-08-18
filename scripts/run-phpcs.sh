#!/bin/sh -l

cd "${GITHUB_WORKSPACE}"

# Env vars override inputs (v1.x behaviour), inputs override defaults.
test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD="${INPUT_PHPCS_STANDARD}"
test -z "${PHPCS_PATH}" && PHPCS_PATH="${INPUT_PHPCS_PATH}"
test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY="${INPUT_PHPCS_SEVERITY}"
test -z "${PHPCS_REPORT}" && PHPCS_REPORT="${INPUT_PHPCS_REPORT}"
test -z "${PHPCS_EXTENSIONS}" && PHPCS_EXTENSIONS="${INPUT_PHPCS_EXTENSIONS}"

# The checkstyle default feeds the bundled problem matcher in both modes.
test -z "${PHPCS_REPORT}" && PHPCS_REPORT=checkstyle

if [ "${USE_PROJECT_TOOLS}" = "true" ]; then
  # Project mode: the committed phpcs.xml.dist supplies the ruleset,
  # paths, severity and extensions unless overridden by inputs.
  if [ ! -x vendor/bin/phpcs ]; then
    echo "::error::vendor/bin/phpcs not found - run composer install" \
      "before this action or set use_project_tools: false."
    exit 1
  fi
  PHPCS_BIN=vendor/bin/phpcs
else
  # Legacy mode: bundled global toolchain and v1.x defaults.
  test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD=Magento2
  test -z "${PHPCS_PATH}" && PHPCS_PATH="app/code/Magic42"
  test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY=8
  test -z "${PHPCS_EXTENSIONS}" && PHPCS_EXTENSIONS=php
  PHPCS_BIN="$(composer global config home)/vendor/bin/phpcs"
fi

echo "PHPCS report: ${PHPCS_REPORT}"
echo "PHPCS standard: ${PHPCS_STANDARD:-(project phpcs.xml.dist)}"
echo "PHPCS path: ${PHPCS_PATH:-(project phpcs.xml.dist)}"
echo "PHPCS severity: ${PHPCS_SEVERITY:-(project phpcs.xml.dist)}"
echo "PHPCS extensions: ${PHPCS_EXTENSIONS:-(project phpcs.xml.dist)}"

# shellcheck disable=SC2086
"${PHPCS_BIN}" \
  --report="${PHPCS_REPORT}" \
  ${PHPCS_SEVERITY:+--severity="${PHPCS_SEVERITY}"} \
  ${PHPCS_EXTENSIONS:+--extensions="${PHPCS_EXTENSIONS}"} \
  ${PHPCS_STANDARD:+--standard="${PHPCS_STANDARD}"} \
  ${PHPCS_PATH:+${PHPCS_PATH}}
