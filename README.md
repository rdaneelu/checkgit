# Script that checks status of all git repos

Works this way:

1. Create a git repo with "git init" ($GIT_DIR must be $WORK_TREE/.git).
2. Make sure your work-tree path is in a file by default in $HOME/.config/.checkgit
<pre>
cd path/to/repo
pwd >> $HOME/.config/.checkgit
</pre>
3. Do step 2 for all your git repositories in your machine
4. Execute checkgit.sh
