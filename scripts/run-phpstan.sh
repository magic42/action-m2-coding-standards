#!/bin/sh -l

cd "${GITHUB_WORKSPACE}"

if [ ! -x vendor/bin/phpstan ]; then
  echo "::error::vendor/bin/phpstan not found - run composer install" \
    "(with require-dev) before this action."
  exit 1
fi

if [ ! -f "${PHPSTAN_CONFIG}" ]; then
  echo "::error::${PHPSTAN_CONFIG} not found - commit a PHPStan config" \
    "that includes the shared magic42 config."
  exit 1
fi

echo "PHPStan config: ${PHPSTAN_CONFIG}"
echo "PHPStan error format: ${PHPSTAN_ERROR_FORMAT}"
echo "PHPStan memory limit: ${PHPSTAN_MEMORY_LIMIT}"

# No paths argument: the committed config owns the analysis scope.
vendor/bin/phpstan analyse \
  --configuration="${PHPSTAN_CONFIG}" \
  --error-format="${PHPSTAN_ERROR_FORMAT}" \
  --memory-limit="${PHPSTAN_MEMORY_LIMIT}" \
  --no-progress
