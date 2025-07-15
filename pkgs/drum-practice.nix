{pkgs, ...}:
# TODO: depends on demucs but its not in nixpkgs
pkgs.writeShellApplication {
  name = "drum-practice";
  runtimeInputs = [
    (pkgs.python3.withPackages
      (ps: with ps; [numpy scipy soundfile aubio]))
  ];
  text = ''
    python ${./scripts/drum_practice.py} "$@"
  '';
}
