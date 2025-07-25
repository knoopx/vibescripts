{pkgs, ...}:
pkgs.writeShellApplication {
  name = "repl";
  runtimeInputs = with pkgs; [
    fzf
    gnugrep
    coreutils
    gawk
  ];
  text = builtins.readFile ./scripts/repl.sh;
  meta = {
    description = "Interactive search through file content using fzf, with flexible preview commands.";
    license = pkgs.lib.licenses.mit;
    maintainers = [];
  };
}
