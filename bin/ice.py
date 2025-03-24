#!/usr/bin/env python

import sys
import os
import subprocess
import multiprocessing

MAX_PROCESSES:int = 4

if (len(sys.argv)<1):
    print("Please provide atleast one CLI argument")

operation_type = sys.argv[1]
print(f"operation_type passed : {operation_type}")

commands=' '.join(sys.argv[2:])
print(f"Commands passed : {commands}")

ignored_list = ["blog/themes",".flatpak-builder",".cache/gh-pages","tmux/plugins"]
directories_ignored_during_runtime = []

def canIgnore(root:str)->bool:

    for ignored_item in ignored_list:
        # print(ignored_item)
        # print(root)
        if ignored_item in root :
            directories_ignored_during_runtime.append((root,ignored_item))
            return True
    return False

def execute_command(root):
     print(f"Root : {root} ")

     command_output = subprocess.Popen(commands, cwd=root, shell=True, stdout=subprocess.PIPE).stdout.read()
     decoded_output = command_output.decode('utf-8')
     print(decoded_output)



def cd_exec(directory_path:str,multi:bool = False):
    directory_path=os.path.expanduser(directory_path)
    # processes = []
    pool = multiprocessing.Pool(processes=MAX_PROCESSES)

    for (root,dirs,file) in os.walk(directory_path,topdown=True):

        # Check if '.git' is in the list of directories
        if '.git' in dirs:
            # Remove '.git' from the list of directories to prevent traversal
            dirs.remove('.git')

            if canIgnore(root):
                continue

            if multi :
                pool.apply_async(execute_command, args=(root,))
            else :
                execute_command(root)

    # Close the pool and wait for all processes to finish
    pool.close()
    pool.join()

    for ignored_dir,matching_regex in directories_ignored_during_runtime :
        print(f"Ignoring directory {ignored_dir} since it matches {matching_regex}")



def exec_in_personal(multi:bool = False):
    cd_exec("~/.password-store",multi)
    cd_exec("~/.dotconfig",multi)
    cd_exec("~/Documents/scripts",multi)

def exec_in_code():
    raise NotImplementedError("$HOME/Code directory should not be used to store code")
    # cd_exec("~/Code",multi)


if __name__  == '__main__':

    multi:bool = False
    if operation_type.endswith("_"):
        operation_type = operation_type[:-1]
        multi = True
        
    match operation_type:
        case "pl":
            exec_in_personal(multi=multi)
        case "code":
            exec_in_code()
        case _:
            print(f"Cannot recognize operation_type {operation_type}")

