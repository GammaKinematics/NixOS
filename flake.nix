{
  description = "NixOS - AL";

  inputs = {
    # Stable nixpkgs for core system (kernel, boot, virtualization)
    nixpkgs.url = "nixpkgs/nixos-25.11";

    # Unstable nixpkgs for desktop/dev tools
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    # Hardware-specific optimizations (fork with Minisforum V3 SE support)
    nixos-hardware.url = "github:GammaKinematics/nixos-hardware";

    # Stylix - system-wide theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Axium browser (custom ungoogled-chromium + thorium opts)
    # Note: Don't use follows - must match exact nixpkgs used when building cache
    axium.url = "github:GammaKinematics/Axium/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      zen-browser,
      ...
    }@inputs:
    let
      system = "x86_64-linux";


      # Stable pkgs for CAD/manufacturing (more reliable builds)
      pkgs-stable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Unstable pkgs for home-manager / desktop / dev
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          inputs.stylix.nixosModules.stylix
          inputs.nixos-hardware.nixosModules.minisforum-v3-se

          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs pkgs-unstable pkgs-stable;
              };
              users.lebowski = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };

    };
}
