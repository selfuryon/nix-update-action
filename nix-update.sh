#!/usr/bin/env bash
set -euo pipefail

# This function will modify all INPUT_* variables so that they don't contain any garbage
sanitizeInputs() {
  # remove all whitespace
  PACKAGES="${PACKAGES// /}"
  BLACKLIST="${BLACKLIST// /}"
}

determinePackages() {
  # determine packages to update
  if [[ -z "$PACKAGES" ]]; then
    PACKAGES=$(nix flake show --json | jq -r '[.packages[] | keys[]] | sort | unique |  join(",")')
  fi
}

updatePackages() {
  # Check tolerance to failed updates
  if [[ $IGNORE_ERRORS == 'true' ]]; then
    set +euo pipefail
  fi

  # update packages
  for PACKAGE in ${PACKAGES//,/ }; do
    if [[ ",$BLACKLIST," == *",$PACKAGE,"* ]]; then
        echo "Package '$PACKAGE' is blacklisted, skipping."
        continue
    fi
    nix-update --flake --commit "$PACKAGE"
    
  done
}

sanitizeInputs
determinePackages
updatePackages
