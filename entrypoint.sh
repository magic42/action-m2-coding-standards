#!/bin/sh -l

# Copy the matcher to a shared volume with the host; otherwise "add-matcher"
# can't find it.
cp /problem-matcher.json ${HOME}/
echo "::add-matcher::${HOME}/problem-matcher.json"

cd $GITHUB_WORKSPACE

test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD=$INPUT_PHPCS_STANDARD
test -z "${PHPCS_PATH}" && PHPCS_PATH=$INPUT_PHPCS_PATH
test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY=$INPUT_PHPCS_SEVERITY
test -z "${PHPCS_REPORT}" && PHPCS_REPORT=$INPUT_PHPCS_REPORT
test -z "${PHPCS_EXTENSIONS}" && PHPCS_EXTENSIONS=$INPUT_PHPCS_EXTENSIONS

test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD=Magento2
test -z "${PHPCS_PATH}" && PHPCS_PATH="app/code/Magic42"
test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY=8
test -z "${PHPCS_REPORT}" && PHPCS_REPORT=checkstyle
test -z "${PHPCS_EXTENSIONS}" && PHPCS_EXTENSIONS=php

echo "PHPCS report: ${PHPCS_REPORT}"
echo "PHPCS standard: ${PHPCS_STANDARD}"
echo "PHPCS path: ${PHPCS_PATH}"
echo "PHPCS severity: ${PHPCS_SEVERITY}"
echo "PHPCS extensions: ${PHPCS_EXTENSIONS}"

sh -c "/root/.composer/vendor/bin/phpcs \
  --report=${PHPCS_REPORT} \
  --standard=${PHPCS_STANDARD} \
  --severity=${PHPCS_SEVERITY} \
  --extensions=${PHPCS_EXTENSIONS} \
  ${PHPCS_PATH}"
