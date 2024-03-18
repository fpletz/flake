{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [ numb-nvim ];

    extraConfigLua = ''
      require('numb').setup()
    '';
  };
}
