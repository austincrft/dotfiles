import os

from subprocess import call

file_to_link_map = {
    'ag/agignore': '~/.agignore',

    'bash/bash_aliases': '~/.bash_aliases',
    'bash/bash_prompt': '~/.bash_prompt',
    'bash/bashrc': '~/.bashrc',
    'bash/fzfrc': '~/.fzfrc',

    'cmd/env.cmd': '~/.env.cmd',

    'universal-ctags/ctags': '~/.ctags',

    'vim/UltiSnips/': '~/.vim/UltiSnips',
    'vim/ftplugin/': '~/.vim/ftplugin',
    'vim/vimrc': '~/.vimrc',
    'visual-studio/vsvimrc': '~/.vsvimrc'
}

unix_format = 'ln -s {target} {link_name}'
dos_format = 'mklink {options} {link_name} {target}'

def is_directory(name):
    return name.endswith('/')

def fix_dos_path(path):
    return path.replace('~', '%USERPROFILE%').replace('/', '\\')

os.chdir('..')
print(f'directory: {os.getcwd()}')

directory = os.path.abspath(os.getcwd())

for key, val in file_to_link_map.items():
    command = ''
    if os.name == 'nt':
        options = '/D' if is_directory(key) else ''
        link_name = fix_dos_path(val)
        target = directory + '\\' + fix_dos_path(key)
        command = dos_format.format(options=options, link_name=link_name, target=target)
    else:
        command = unix_format.format(target=key, link_name=key)

    print(command)
    call(command, shell=True)
