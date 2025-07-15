{pkgs, ...}:
pkgs.writeShellApplication {
  name = "say";
  runtimeInputs = with pkgs; [
    curl
    jq
    mpv
  ];
  text = builtins.readFile ./scripts/say.sh;
}
