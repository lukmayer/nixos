# configuration.nix(5) man page / NixOS manual (accessible by running ‘nixos-help’).
# TODO: reorganize for clarity
{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;

  # R packages
  commonRPackages = with pkgs.rPackages; [
    tidyverse BayesFactor brms lme4 lmerTest zoo readxl languageserver kableExtra emmeans rstatix
    stringr DT this_path showtext cowplot patchwork reticulate pROC
  ];

  # R with packages
  myR = pkgs.rWrapper.override { packages = commonRPackages; };

  # radian with the same packages
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

  services.xserver = {
    xkb.layout = "de,us";
    xkb.variant = "";
    xkb.options = "grp:win_space_toggle";
  };

  # Garbace collection
  nix.gc = {
    automatic = true;          
    dates     = "03:30 daily"; 
    options   = "--delete-older-than 14d";
  };

  # SERVICES
  services = {
    xserver.enable = true;
    printing.enable = true;
    openssh.enable = true;
    xserver.wacom.enable = true;

    # DM
    xserver.displayManager.gdm.enable = true;
    displayManager.sddm.enable = false;
    displayManager.sddm.wayland.enable = false;

    # KDE
    desktopManager.plasma6.enable = true;

  };

  # Exclude packages from DE
  #KDE
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa # Simple music player aiming to provide a nice experience for its users
    kdePackages.kdepim-runtime # Akonadi agents and resources
    kdePackages.kmahjongg # KMahjongg is a tile matching game for one or two players
    kdePackages.kmines # KMines is the classic Minesweeper game
    kdePackages.konversation # User-friendly and fully-featured IRC client
    kdePackages.kpat # KPatience offers a selection of solitaire card games
    kdePackages.ksudoku # KSudoku is a logic-based symbol placement puzzle
    kdePackages.ktorrent # Powerful BitTorrent client
    kdePackages.konsole
    kdePackages.kate
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
    shell = pkgs.fish;
    description = "Lm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Fish
  programs.fish.enable = true;

  # Emacs
  services.emacs = {
    enable = true;
    package = myEmacs;
  };
 
  # Neovim
  programs.neovim = {
    enable = true;
  };
  
  environment.systemPackages = with pkgs; [
    
    # CLI
    lunarvim
    kitty # terminal
    zellij # multiplexer
    btop # system-monitor
    ncdu # disk-usage
    fzf # fuzzy-find
    fd # faster find
    yazi # file-manager
    ripgrep # better grep
    zoxide # frecency commands
    carapace # argument suggestions
    
    # essentials
    nodejs
    unzip
    wget
    curl
    git

    # coding
    typst
    quarto
    vscodium # manual setup
    myEmacs

    # latex
    (texliveFull.withPackages (ps: with ps; [
        scheme-basic
        standalone
        varwidth
        scontents
        xcolor
    ]))
    
    # python
    (python3.withPackages (ps: with ps; [
      numpy
      pandas
      matplotlib
      scipy
      pygame
      ipython
    ])) # TODO: define myPy in let block

    # julia
    #julia-bin # manual package installation
    (julia.withPackages (ps: with ps; [
      DataFrames
      Turing
      Gadfly
    ]))

    
    # R
    myR
    myRadian

    # web
    vivaldi # manual configuration
    protonvpn-gui # manually add to start-up
    protonmail-bridge-gui # manually add to start-up

    # media
    mpv
    calibre
    zotero # manual extension installation
    libreoffice
    stremio
    pdfarranger
    xournalpp   
 
    # files
    syncthing # manual setup
    deja-dup

    # wayland
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland
    libwacom
    libinput

    #KDE
    kdePackages.krohnkite
  ];
  
  environment.variables.PATH = "$HOME/.config/emacs/bin";

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

  # EXPERIMENTAL
  nix.settings.experimental-features = [ "flakes" "nix-command" ];


  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
