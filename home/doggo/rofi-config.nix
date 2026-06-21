{
  home.file.".config/rofi/config.rasi".text = ''
@import "catppuccin-mocha"
@import "catppuccin-default"

configuration {
  modes: "run,ssh,drun";
  font: "mono 12";
  show-icons: true;
  icon-theme: "Papirus Dark";

  location: 0;
  yoffset: 0;
  xoffset: 0;
  fixed-num-lines: true;

  ml-row-down: "ScrollDown";                                                                                      
  me-select-entry: "MousePrimary";                                                                                 
  me-accept-entry: "MouseDPrimary";                                                                                
  me-accept-custom: "Control+MouseDPrimary";
}
'';
}
