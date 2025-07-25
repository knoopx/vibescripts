{pkgs, ...}:
pkgs.writeShellApplication {
  name = "todos";
  runtimeInputs = with pkgs; [
    gnused
    gnugrep
    coreutils
    gum
  ];
  text = builtins.readFile ./scripts/todos.sh;
  meta = {
    description = "Interactive TODO list manager for markdown checkboxes using gum.";
    license = pkgs.lib.licenses.mit;
    maintainers = [];
  };
}
