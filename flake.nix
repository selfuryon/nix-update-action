{
  description = "Etherno IaC Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    # pre-commit-hooks-nix = {
    #   url = "github:hercules-ci/pre-commit-hooks.nix/flakeModule";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # utils
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    statix = {
      url = "github:nerdypepper/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        pkgs,
        config,
        lib,
        self',
        inputs',
        ...
      }: let
        inherit (pkgs) mkShellNoCC;
      in {
        devShells.default = mkShellNoCC {
          packages = with pkgs; [
            shellcheck
          ];
        };
        treefmt.config = {
          inherit (config.flake-root) projectRootFile;
          package = pkgs.treefmt;

          programs = {
            alejandra.enable = true;
            prettier.enable = true;
          };
        };

        formatter = config.treefmt.build.wrapper;
      };
    };
}
