{ nixtamal, importFlake, ... }:

{
  imports = [ (importFlake nixtamal.nix-amd-ai).nixosModules.default ];

  hardware.amd-npu = {
    enable = true;
    enableNPU = false;
    enableFastFlowLM = false; # My laptop's hawk point NPU isn't supported
    enableLemonade = true; # Note: the default web port is 13305
    enableROCm = true;
    enableVulkan = true;
    enableImageGen = true;
    lemonade.user = "doggo";
  };
  users.users.doggo.extraGroups = ["video" "render"];
}