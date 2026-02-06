# Zed Editor configuration
{ pkgs-unstable, ... }:

{

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    # This populates the userSettings "auto_install_extensions"
    extensions = [
      "nix"
      "odin"
      "slint"
      "dockerfile"
      "docker-compose"
      "latex"
      "make"
      "log"
      "csv"
    ];

    # Everything inside of these brackets are Zed options
    userSettings = {
      # Disable all AI features (including Claude Code ACP agents)
      disable_ai = true;

      # Disable collaboration/AI features
      assistant = { enabled = false; };
      collaboration_panel = { button = false; };
      chat_panel = { button = false; };
      notification_panel = { button = false; };
      title_bar = { show_sign_in = false; };

      # Hide UI panels
      diagnostics = { button = false; };
      debugger = { button = false; };

      # Disable edit predictions completely
      features = { edit_prediction_provider = "none"; };
      show_edit_predictions = false;

      hour_format = "hour24";
      auto_update = false;

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = true;
        dock = "right";
        line_height = "comfortable";
        shell = "system";
        toolbar = {
          title = true;  # Shows terminal title (e.g. "zsh" or running command) in panel header
        };
        working_directory = "current_project_directory";
      };

      vim_mode = false;

      base_keymap = "VSCode";

      show_whitespaces = "selection";

      # Disable all language servers globally
      enable_language_server = false;

      # Disable Claude Code integration (prevents auto-launching claude-code-acp)
      context_servers = { };
    };
  };
}
