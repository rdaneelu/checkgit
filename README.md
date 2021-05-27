# Script that checks status of all git your different git repositories
## Example of Output:
<pre>
REPOSITORIES:
repo1: ALL OK (Means upstream if exist is syncronised with local and no local changes from last commit)
repo2: Upstream Ahead local
repo3: Upstream Behind local
repo4: Local changes
repo5: Upstream {Ahead/Behind} local, Local changes
</pre>

### How it Works:

1. Create a git repo with "git init" ($GIT_DIR must be $WORK_TREE/.git).
2. Make sure your work-tree path is in a file by default in $HOME/.config/.checkgit
<pre>
cd path/to/repo
pwd >> $HOME/.config/.checkgit
</pre>
3. Do step 2 for all your git repositories in your machine
4. Execute checkgit.sh
