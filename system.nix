# Nice way to avoid nixos channels & I can use it since I use a >= 26.05 version
let
  nixtamal = import ./tamal {};
in import "${nixtamal.nixpkgs}/nixos" {
  configuration = ./configuration.nix;
  specialArgs = rec {
    inherit nixtamal;

    # Function to import flakes (defined here instead of _module.args so it doesn't crash when used inside of imports = [])
    importFlake = src:
      assert builtins.pathExists src;
      builtins.getFlake (builtins.unsafeDiscardStringContext src);
  };
}