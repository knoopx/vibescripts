{
  description = "vibescripts: custom scripts as Nix flake packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        callPackage = pkgs.callPackage;
        vibescriptsPkgs = {
          importantize = callPackage ./pkgs/importantize.nix {};
          strip-python-comments = callPackage ./pkgs/strip-python-comments.nix {};
          say = callPackage ./pkgs/say.nix {};
          raise-or-open-url = callPackage ./pkgs/raise-or-open-url.nix {};
          nixos-changelog = callPackage ./pkgs/nixos-changelog.nix {};
          drum-practice = callPackage ./pkgs/drum-practice.nix {};
          niri-rotate-display-desktop-items = callPackage ./pkgs/niri-rotate-display-desktop-items.nix {};
        };
      in {
        packages = vibescriptsPkgs // {default = vibescriptsPkgs;};
        legacyPackages = vibescriptsPkgs;
      }
    );
}
