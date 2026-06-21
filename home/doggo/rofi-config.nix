{ ... }:

{
  programs.rofi = {
    enable = true;
    font = "mono 12";
    location = "center";

    extraConfig = {
      modes = "run,ssh,drun";
      "show-icons" = true;
      "icon-theme" = "Papirus Dark";
      yoffset = 0;
      xoffset = 0;
      "fixed-num-lines" = true;
      "ml-row-down" = "ScrollDown";
      "me-select-entry" = "MousePrimary";
      "me-accept-entry" = "MouseDPrimary";
      "me-accept-custom" = "Control+MouseDPrimary";
    };
  };
}
