# Inputs must be defined here because they must be a static set. No calculations are allowed, meaning they can't be stored in other files.
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    latest.url = "github:nixos/nixpkgs";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";
    # Make sure to follow nixpkgs to unclutter lock file
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    headscale = {
      url = "github:juanfont/headscale/v0.23.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvfetcher.follows = "nvfetcher";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    schizofox = {
      url = "github:schizofox/schizofox";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixtendo-switch = {
      url = "github:nyawox/nixtendo-switch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    psilocybin = {
      # url = "github:nyawox/psilocybin";
      url = "github:nyawox/psilocybin/playground";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "github:nyawox/NixVirt/fakecore";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    catppuccin-gitui = {
      url = "github:catppuccin/gitui";
      flake = false;
    };
    catppuccin-alacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };
    catppuccin-emacs = {
      url = "github:catppuccin/emacs";
      flake = false;
    };
    catppuccin-zathura = {
      url = "github:catppuccin/zathura";
      flake = false;
    };
    catppuccin-element = {
      url = "github:catppuccin/element";
      flake = false;
    };
    catppuccin-tridactyl = {
      url = "github:lonepie/catppuccin-tridactyl";
      flake = false;
    };
    catppuccin-fcitx5 = {
      url = "github:catppuccin/fcitx5";
      flake = false;
    };
    catpuccin-home-assistant = {
      url = "github:catppuccin/home-assistant";
      flake = false;
    };
    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
    };
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
    ff-ultima = {
      url = "github:soulhotel/ff-ultima/1.8.6";
      flake = false;
    };
    aria-onion = {
      url = "github:sn0b4ll/aria2-onion-downloader";
      flake = false;
    };
    doom-banners = {
      url = "github:jeetelongname/doom-banners";
      flake = false;
    };
    tree-sitter-kdl = {
      url = "github:tree-sitter-grammars/tree-sitter-kdl";
      flake = false;
    };
    hass-nature-remo = {
      url = "github:Haoyu-UT/HomeAssistantNatureRemo";
      flake = false;
    };
    hass-smartir = {
      url = "github:smartHomeHub/smartir";
      flake = false;
    };
    hass-kiosk-mode = {
      url = "github:NemesisRE/kiosk-mode";
      flake = false;
    };
    hass-tapo = {
      url = "github:petretiandrea/home-assistant-tapo-p100";
      flake = false;
    };
    taildrop-notifier.url = "github:nyawox/taildrop-notifier";
    impermanence.url = "github:nix-community/impermanence";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nur.url = "github:nix-community/nur";
    flake-parts.url = "github:hercules-ci/flake-parts";
    madness.url = "github:antithesishq/madness";
  };

  outputs = args: import ./modules/outputs.nix args;
}
