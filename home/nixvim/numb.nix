{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ numb-nvim ];

  extraConfigLua = ''
    require('numb').setup()
  '';
}
