import os

from subprocess import call

all_os_files = {
    'ag/agignore': '~/.agignore',

    'bash/bash_aliases': '~/.bash_aliases',
    'bash/bash_prompt': '~/.bash_prompt',
    'bash/bashrc': '~/.bashrc',
    'bash/fzfrc': '~/.fzfrc',

    'universal-ctags/ctags': '~/.ctags',

    'vim/snippets/': '~/.vim/snippets',
    'vim/ftplugin/': '~/.vim/ftplugin',
    'vim/vimrc': '~/.vimrc'
}

windows_files = {
    'cmd/env.cmd': '~/.env.cmd',
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

os_name = os.name

target_files = all_os_files.copy()
if os_name == 'nt':
    target_files.update(windows_files)

for key, val in target_files.items():
    command = ''
    if os_name == 'nt':
        options = '/D' if is_directory(key) else ''
        link_name = fix_dos_path(val)
        target = directory + '\\' + fix_dos_path(key)
        command = dos_format.format(options=options, link_name=link_name, target=target)
    else:
        target = directory + f'/{key}'
        command = unix_format.format(target=target, link_name=val)

    print(command)
    call(command, shell=True)
