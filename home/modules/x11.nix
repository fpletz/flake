{
  xresources.properties = {
    "Xft.hinting" = "1";
    "Xft.hintstyle" = "hintslight";
    "Xft.antialias" = "1";
    "Xft.rgba" = "rgb";
  };
  services.xsettingsd = {
    enable = true;
    settings = {
      "Xft/Hinting" = true;
      "Xft/HintStyle" = "hintslight";
      "Xft/Antialias" = true;
      "Xft/RGBA" = "rgb";
    };
  };
}
