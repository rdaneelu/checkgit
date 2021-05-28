# Script that list and checks status of all git your different git repositories
## Example of Output:
<pre>
REPOSITORIES:
repo1: ALL OK (Means upstream if exist is syncronised with local and no local changes from last commit)
repo2: Upstream Ahead local (Upstream is ahead 1 or several commits from local, no local changes since last local commit)
repo3: Upstream Behind local (Upstream is behind 1 or several commits from local, no local changes since last local commit)
repo4: Local changes (Upstream is syncronised, local changes from last commit)
repo5: Upstream {Ahead/Behind} local, Local changes
</pre>

### How it Works:

1. Create a git repo with "git init" ($GIT_DIR must be $WORK_TREE/.git).
2. Make sure your work-tree path is in a file by default in $HOME/.config/.checkgit
<pre>
/home/user/work/project1      ~name_your_repo
/home/user/github/
</pre>
3. Execute checkgit.sh
4. Choose to fetch remote repositories if you didn't recently
5. Choose to ignore or include untracked files

# Fixed:
1. Duplicated paths in config file duplicated the output
2. If no upstream was configured in the repo it always told you Upstream ahead of local

# Features
1. Now it tells you that no upstream is configured in the repository.
2. And if a name is given to 2 or more different paths in the config file it gives a number
at the end of the name in order.
