{ pkgs-stable, ... }:

{
  # ============================================================================
  # Git Configuration
  # ============================================================================
  programs.git = {
    enable = true;
    package = pkgs-stable.git;

    settings = {
      user.name = "GammaKinematics";
      user.email = "gamma.kinematics@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      # Use SSH for GitHub
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };

    # Delta - better diff viewer
    # delta = {
    #   enable = true;
    #   options = {
    #     navigate = true;
    #     light = false;
    #     line-numbers = true;
    #   };
    # };

    # Aliases
    # aliases = {
    #   co = "checkout";
    #   br = "branch";
    #   ci = "commit";
    #   st = "status";
    #   lg = "log --oneline --graph --decorate";
    # };

    # SSH signing (for verified commits)
    # signing = {
    #   key = "~/.ssh/id_ed25519.pub";
    #   signByDefault = true;
    # };
    # extraConfig.gpg.format = "ssh";
  };

  # ============================================================================
  # SSH Configuration
  # ============================================================================
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        host = "github.com";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      # Add more hosts as needed
      # "gitlab.com" = {
      #   host = "gitlab.com";
      #   identityFile = "~/.ssh/id_ed25519";
      #   identitiesOnly = true;
      # };
    };
  };
}
