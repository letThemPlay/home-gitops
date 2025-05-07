{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          devShells.default =
            let
              fhs = pkgs.buildFHSEnv {
                name = "terraform-fhs";
                targetPkgs = pkgs: builtins.attrValues { inherit (pkgs) kubectl fluxcd talosctl terraform nixfmt-rfc-style; };
                runScript = "zsh";
              };
            in
            fhs.env;
        };
    };
}
