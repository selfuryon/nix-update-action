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
    mission-control.url = "github:Platonic-Systems/mission-control";

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
        inputs.mission-control.flakeModule
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
        inherit (config.mission-control) installToDevShell;
        inherit (pkgs) mkShellNoCC;
      in {
        devShells.default = installToDevShell (mkShellNoCC {
          packages = with pkgs; [
            shellcheck
          ];
        });
        treefmt.config = {
          inherit (config.flake-root) projectRootFile;
          package = pkgs.treefmt;

          programs = {
            alejandra.enable = true;
            prettier.enable = true;
          };
        };

        formatter = config.treefmt.build.wrapper;
        mission-control = {
          scripts = {
            fmt = {
              category = "Tools";
              description = "Format the source tree";
              exec = "${lib.getExe config.treefmt.build.wrapper}";
            };
          };
        };
      };
    };
}
