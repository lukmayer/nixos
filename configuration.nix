# configuration.nix(5) man page / NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;

  # R packages
  commonRPackages = with pkgs.rPackages; [
    tidyverse BayesFactor brms lme4 lmerTest zoo readxl languageserver kableExtra emmeans rstatix
    stringr DT this_path showtext cowplot patchwork reticulate pROC
  ];

  # R with those packages
  myR = pkgs.rWrapper.override { packages = commonRPackages; };

  # radian that starts the same R and pre-loads the same packages
  myRadian = pkgs.radianWrapper.override { packages = commonRPackages; };

  myEmacs =
    (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]);

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

  hardware.bluetooth = {
    enable        = true;   # loads the kernel modules + bluetoothd
    powerOnBoot   = true;   # turn the adapter on automatically
  };
  # services.blueman.enable   = true;

  services.xserver = {
    xkb.layout = "de,us";
    xkb.variant = "";
    xkb.options = "grp:win_space_toggle";
  };

  # Garbace collection
  nix.gc = {
    automatic = true;          # create nix-gc.service + timer
    dates     = "03:30 daily"; # run each night (cron-style syntax)
    options   = "--delete-older-than 14d";
  };

  # SERVICES
  services = {
    xserver.enable = true;
    printing.enable = true;
    openssh.enable = true;

    xserver.wacom.enable = true;
    xserver.displayManager.gdm.enable = true;
    xserver.desktopManager.gnome.enable = true;
    gnome.core-apps.enable = false;
    gnome.core-developer-tools.enable = false;
    gnome.games.enable = false;

  };

  #GNOME
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

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
    shell = pkgs.fish;
    description = "Lm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Nix-ld 
  programs.nix-ld.enable = true;

  # Fish
  programs.fish.enable = true;

  # Emacs
  services.emacs = {
    enable = true;
    package = myEmacs;
  };
  
  
  environment.systemPackages = with pkgs; [
    
    # CLI
    kitty # terminal
    zellij # multiplexer
    helix # text editor
    btop # system-monitor
    ncdu # disk-usage

    lazygit # git interface
    fzf # fuzzy-find
    fd # faster find
    yazi # file-manager
    ripgrep # better grep
    zoxide # frecency commands
    carapace # argument suggestions
    
    # coding
    gcc
    gnumake
    cmake
    libtool
    pkg-config
    libvterm
    nodejs
    unzip
    wget
    curl
    git
    
    typst
    quarto
    vscodium # manual setup
    myEmacs

    # latex
    (texliveFull.withPackages
      (ps: with ps; [
        scheme-basic
        standalone
        varwidth
        scontents
        xcolor
    ]))
    #poppler_utils # not sure if needed
    #ghostscript # not sure if needed
    #imagemagick # not sure if needed
    #pdf2svg # not sure if needed

    
    # python
    (python3.withPackages (ps: with ps; [
      numpy
      pandas
      matplotlib
      scipy
      pygame
      ipython
    ]))

    # julia
    julia-bin # manual package installation

    # R
    myR
    myRadian

    # web
    vivaldi # manual configuration
    protonvpn-gui # manually add to start-up
    protonmail-bridge-gui # manually add to start-up

    # media
    mpv
    yt-dlp
    calibre
    zotero # manual extension installation
    libreoffice
    stremio
    pdfarranger
    xournalpp   
    evince
 
    # files
    syncthing # manual setup
    deja-dup

    # wayland
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland

    #GNOME
    gnome-system-monitor
    nautilus
    adwaita-icon-theme
    libwacom
    libinput
    gnome-themes-extra
    gnome-tweaks
    gnomeExtensions.just-perfection
    gnomeExtensions.caffeine
    gnomeExtensions.blur-my-shell
    gnomeExtensions.astra-monitor

  ];


  environment.variables = {
    QUARTO_R = "${myR}/bin/R";
    RETICULATE_PYTHON = "${pkgs.python3}/bin/python3";

    EDITOR = "emacsclient -c -a ''";

    # WIP - packages still not found during quarto render
    QUARTO_JULIA = "${pkgs.julia-bin}/bin/julia";
    QUARTO_JULIA_RUNTIME_DIR = "$HOME/.local/state/quarto-julia";
  };
  
  environment.shellAliases = {
    e = "emacsclient -nw ''";
    em = "emacsclient -c -a ''";
  };
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
