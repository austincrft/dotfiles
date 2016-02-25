atom.packages.onDidActivatePackage (pack) ->
  if pack.name == 'ex-mode'
    Ex = pack.mainModule.provideEx()
    editor = atom.workspace.getActiveTextEditor()
    Ex.registerCommand 'noh', -> atom.commands.dispatch(atom.views.getView(editor), 'vim-mode-plus:clear-highlight-search')

