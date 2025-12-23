# Zed Editor configuration
{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    nil # Nix LSP
    nixd # Alternative Nix LSP
    nixfmt-rfc-style # Nix formatter
  ];

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    # This populates the userSettings "auto_install_extensions"
    extensions = [
      "nix"
      "dockerfile"
      "docker-compose"
      "latex"
      "make"
      "log"
      "csv"
    ];

    # Everything inside of these brackets are Zed options
    userSettings = {
      assistant = {
        enabled = true;
        default_model = {
          provider = "anthropic";
          model = "claude-opus-4-5-latest";
        };
      };

      hour_format = "hour24";
      auto_update = false;

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
          on = {
            directories = [
              ".env"
              "env"
              ".venv"
              "venv"
            ];
            activate_script = "default";
          };
        };
        line_height = "comfortable";
        option_as_meta = false;
        shell = "system";
        toolbar = {
          title = true;
        };
        working_directory = "current_project_directory";
      };

      lsp = {
        nil = {
          binary = {
            path_lookup = true;
          };
        };
        nixd = {
          binary = {
            path_lookup = true;
          };
        };
      };

      languages = {

      };

      vim_mode = false;

      # Tell Zed to use direnv and direnv can use a flake.nix environment
      load_direnv = "shell_hook";

      base_keymap = "VSCode";

      show_whitespaces = "all";
    };
  };
}
