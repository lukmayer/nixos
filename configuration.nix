# configuration.nix(5) man page / NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;

in

{
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.users.lm = {
    home.stateVersion = "25.05";
  };

  home-manager.useGlobalPkgs = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/Los_Angeles";

  # Language
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

services.xserver = {
  xkb.layout = "de,us";
  xkb.variant = "";
  xkb.options = "grp:win_space_toggle";
};


# SERVICES
services = {
  xserver.enable = true;
  printing.enable = true;
  openssh.enable = true;

  # KDE
  desktopManager.plasma6.enable = true;

  displayManager.sddm = {
    enable = true;
      wayland.enable = true;
    theme = "catppuccin-mocha";
    #package = pkgs.kdePackages.sddm; #needs to be commented out to work
  };


};



environment.plasma6.excludePackages = with pkgs; [
    kdePackages.kdepim-runtime # Akonadi agents and resources
    kdePackages.kmahjongg # KMahjongg is a tile matching game for one or two players
    kdePackages.kmines # KMines is the classic Minesweeper game
    kdePackages.kpat # KPatience offers a selection of solitaire card games
    kdePackages.ksudoku # KSudoku is a logic-based symbol placement puzzle
    kdePackages.ktorrent # Powerful BitTorrent client
  ];

  # Console keymap
  console.keyMap = "de";

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Users
  # Don't forget to set a password with ‘passwd’.
  users.users.lm = {
    isNormalUser = true;
    description = "Lm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # PACKAGES
  environment.systemPackages = with pkgs; [

    # coding
    wget
    helix
    git # manual ssh configuration
    quarto
    typst
    zellij # manual setup
    vscodium

    (python3.withPackages (ps: with ps; [
      numpy
      pandas
      matplotlib
      scipy
      pygame
    ]))

    julia # manual package installation

    (rWrapper.override {packages = with rPackages; [
      tidyverse
      BayesFactor
      lme4
      brms
      zoo
      ];
    })

    # web
    vivaldi # manual configuration
    brave
    tor
    protonvpn-gui # manually add to start-up
    protonmail-bridge-gui # manually add to start-up

    # media
    mpv
    calibre
    xournalpp
    zotero # manual extension installation
    libreoffice
    stremio

    # files
    syncthing # manual setup
    deja-dup

    # KDE
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdiff3 # Compares and merges 2 or 3 files or directories
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland

    kde-rounded-corners #for border colors

    (catppuccin-sddm.override {
      flavor = "mocha";
      font  = "Noto Sans";
      fontSize = "16";
      background = "${./curves.png}";
      loginBackground = true;
    })

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # EXPERIMENTAL
  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
