{pkgs, ...}:
pkgs.writeShellApplication {
  name = "nixos-changelog";
  runtimeInputs = with pkgs; [nix coreutils];
  text = builtins.readFile ./scripts/nixos-changelog.sh;
}
