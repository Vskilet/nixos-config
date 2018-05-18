self: super:
{
  nvim = super.neovim.override {
    vimAlias = true;
    configure = {
      packages.myVimPackage = with super.vimPlugins; {
        # loaded on launch
        start = [ sensible polyglot ale vim-startify airline ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
        # To automatically load a plugin when opening a filetype, add vimrc lines like:
        # autocmd FileType php :packadd phpCompletion
      };
      customRC = ''
        filetype plugin on
        set background=dark
        set number
      '';
    };
  };
}
