# Nice way to avoid nixos channels & I can use it since use a >= 26.05 version
let
  nixtamal = import ./tamal {};
in import "${nixtamal.nixpkgs}/nixos" {
  configuration = ./configuration.nix;
  specialArgs = { inherit nixtamal; };
}