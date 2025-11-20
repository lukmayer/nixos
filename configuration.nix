# configuration.nix(5) man page / NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;

  # R packages
  commonRPackages = with pkgs.rPackages; [
    tidyverse BayesFactor brms lme4 lmerTest zoo readxl languageserver kableExtra emmeans rstatix
    stringr DT this_path showtext cowplot patchwork reticulate pROC MCMCpack rjags
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

  networking.hostName = "nixos";

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
    enable        = true;   
    powerOnBoot   = true;   
  };

  services.xserver = {
    xkb.layout = "de,us";
    xkb.variant = "";
    xkb.options = "grp:win_space_toggle";
  };

  # Garbage collection
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
    kdePackages.elisa 
    kdePackages.kdepim-runtime 
    kdePackages.kmahjongg 
    kdePackages.kmines 
    kdePackages.konversation 
    kdePackages.kpat 
    kdePackages.ksudoku 
    kdePackages.ktorrent 
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
  };

  # Users
  # Don't forget to set a password with ‘passwd’.
  users.users.lm = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Lm";
    extraGroups = [ "networkmanager" "wheel" ];
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

  # Fonts
  fonts.packages = with pkgs; [
    iosevka
  ];

  
  environment.systemPackages = with pkgs; [
    
    # CLI
    kitty # terminal
    zellij # multiplexer
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
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

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
      jupyter
      numpy
      pandas
      matplotlib
      scipy
      pygame
      ipython
      python-lsp-server
    ])) # TODO: define myPy in let block

    # julia
    julia-bin # manual package installation
    
    # R
    myR
    myRadian

    # web
    vivaldi # manual configuration
    librewolf
    tor-browser
    protonvpn-gui # manually add to start-up
    protonmail-bridge-gui # manually add to start-up
    
    # media
    mpv
    calibre
    zotero 
    libreoffice
    stremio
    xournalpp   
 
    # files
    syncthing # manual setup
    deja-dup

    # wayland
    wayland-utils 
    wl-clipboard 
    libwacom
    libinput

    #KDE
    kdePackages.krohnkite
    kde-rounded-corners
  ];
  
  environment.variables.PATH = "$HOME/.config/emacs/bin";

  environment.variables = {
    
    QUARTO_R = "${myR}/bin/R";
    RETICULATE_PYTHON = "${pkgs.python3}/bin/python3";

    EDITOR = "emacsclient -c -a ''";
  };
  
  # EXPERIMENTAL
  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}



