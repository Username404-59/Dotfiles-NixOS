{ pkgs, nixtamal, functions, ... }:

{
  hardware.graphics = {
    # Mesa-git because why not
    package = functions.mkUnstable pkgs.mesa;
    package32 = functions.mkUnstable pkgs.pkgsi686Linux.mesa;
  };
}