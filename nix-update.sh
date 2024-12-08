#!/usr/bin/env bash
set -euo pipefail

enterFlakeFolder() {
  if [[ -n "$PATH_TO_FLAKE_DIR" ]]; then
    cd "$PATH_TO_FLAKE_DIR"
  fi
}

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
  # update packages
  for PACKAGE in ${PACKAGES//,/ }; do
    if [[ ",$BLACKLIST," == *",$PACKAGE,"* ]]; then
        echo "Package '$PACKAGE' is blacklisted, skipping."
        continue
    fi
    echo "Updating package '$PACKAGE'."
    # if current version is unstable, update to latest commit of default branch
    CURRENT_VERSION=$(nix derivation show .#"$PACKAGE" | jq -r '.[].env.version')
    if [[ $CURRENT_VERSION == *"unstable"* ]]; then
      VERSION_FLAG="branch"
    else
      VERSION_FLAG="stable"
    fi
    nix-update --flake --commit --version="$VERSION_FLAG" "$PACKAGE" 1>/dev/null
  done
}

enterFlakeFolder
sanitizeInputs
determinePackages
updatePackages
