{ ... }:

{
  programs.rofi = {
    enable = true;

    settings = {
      font = "mono 12";
      location = 0;
      yoffset = 0;
      xoffset = 0;
      mode = "run,ssh,drun";

      "show-icons" = true;
      "icon-theme" = "Papirus Dark";
      "fixed-num-lines" = true;
      "ml-row-down" = "ScrollDown";
      "me-select-entry" = "MousePrimary";
      "me-accept-entry" = "MouseDPrimary";
      "me-accept-custom" = "Control+MouseDPrimary";
    };
  };
}
