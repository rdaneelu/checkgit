# Script that list and checks status of all git your different git repositories

### How it Works:

1. Create a git repo with "git init" ($GIT_DIR must be $WORK_TREE/.git).
2. Make sure your work-tree path is in a file by default in $HOME/.config/.checkgit
3. Execute checkgit.sh
4. Choose to fetch remote repositories if you didn't recently
5. Choose to ignore or include untracked files

The file by default is $HOME/.config/.checkgit and should have this 
<pre>
/home/user/work/project1      ~name_repo
/home/user/github/            ~name_repo2
/run/media/019E28730912/project2 
</pre>
if the line does not provide a name '~name' it defaults to the name of the directory is in.


### All Outputs
\*\*This script only checks the remote set as upstream to the repository
<pre>
REPOSITORIES:
Project0: ALL OK
Project1: Upstream Ahead Local
Project2: Upstream Behind Local
Project3: Local Changes
Project4: Upstream Ahead Local, Local Changes
Project5: Upstream Behind Local, Local Changes
Project6: ALL OK (No upstream detected in repository)
Project7: Local Changes (No upstream detected in repository)
</pre>

# Fixed:
1. Duplicated paths in config file duplicated the output
2. If no upstream was configured in the repo it always told you Upstream ahead of local

# Features
1. Now it tells you if the repository doesn't have an upstream remote configured.
2. If a name is given to 2 or more different paths in the config file it gives a number
at the end of the name in order.
