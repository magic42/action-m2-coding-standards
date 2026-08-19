#!/bin/sh -l

cd "${GITHUB_WORKSPACE}"

if [ ! -x vendor/bin/phpmd ]; then
  echo "::error::vendor/bin/phpmd not found - run composer install" \
    "(with require-dev) before this action."
  exit 1
fi

if [ ! -f "${PHPMD_RULESET}" ]; then
  echo "::error::${PHPMD_RULESET} not found - commit a PHPMD ruleset" \
    "that references the shared magic42 rules."
  exit 1
fi

echo "PHPMD path: ${PHPMD_PATH}"
echo "PHPMD format: ${PHPMD_FORMAT}"
echo "PHPMD ruleset: ${PHPMD_RULESET}"

# A phpmd.baseline.xml next to the ruleset is applied automatically by
# PHPMD; violations above the baseline exit non-zero.
vendor/bin/phpmd "${PHPMD_PATH}" "${PHPMD_FORMAT}" "${PHPMD_RULESET}"
