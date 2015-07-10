atom.commands.add 'atom-text-editor', 'custom:wait-key-press', (e)->
  oe = e.originalEvent
  char = String.fromCharCode(oe.which)
  char = char.toLowerCase() unless oe.shift
  atom.workspace.getActivePaneItem().insertText(char)
