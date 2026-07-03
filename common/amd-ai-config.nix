{ ... }:

{
  hardware.amd-npu = {
    enable = true;
    enableNPU = false;
    enableFastFlowLM = false; # My laptop's hawk point NPU isn't supported
    enableLemonade = true;
    enableROCm = true;
    enableVulkan = true;
    enableImageGen = true;
    lemonade.user = "doggo";
  };
  users.users.doggo.extraGroups = ["video" "render"];
}