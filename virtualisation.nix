{ config, pkgs, ... }:

{
  # Libvirt/QEMU virtualisation
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "lebowski" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
    # Use the rootless mode - run Docker daemon as non-root user
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
