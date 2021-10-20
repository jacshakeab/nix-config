{ pkgs, lib, stdenv, writeShellScriptBin, installShellFiles, coreutils }:

with lib;

stdenv.mkDerivation {
  name = "setwallpaper";
  version = "1.0";
  src = writeShellScriptBin "setwallpaper" ''
    if [ "$1" == "-L" ]; then
      find ${pkgs.wallpapers}/share/backgrounds -type f -not -path '*/\.*' -printf "%f\n"
      exit 0
    elif [ "$1" == "-R" ]; then
      wallpaper=$(setwallpaper -L | ${coreutils}/bin/shuf -n 1)
      echo $wallpaper
      exit 0
    elif [ "$1" == "generate" ]; then
      wallpaper="null"
    else
      wallpaper="\"$1\""
    fi

    echo "$wallpaper" > /dotfiles/users/$USER/current-wallpaper.nix && \
    home-manager switch --flake /dotfiles ''${@:2}
  '';
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ installShellFiles ];
  installPhase = ''
    install -Dm 0755 $src/bin/setwallpaper $out/bin/setwallpaper
    installShellCompletion --cmd setwallpaper \
      --fish <(echo 'complete -c setwallpaper -d "Which wallpaper to set" -r -f -a "(setwallpaper -L)"')
  '';

  meta = {
    description = "Script for setting wallpapers on my hm setup";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}
