# ========================================
# Git Aliases (PowerShell version, prefix: G)
# ========================================

function G { git @args }
Remove-Alias -Name Gc -Force -ErrorAction SilentlyContinue
Remove-Alias -Name Gm -Force -ErrorAction SilentlyContinue
Remove-Alias -Name Gp -Force -ErrorAction SilentlyContinue
# Branch (b)
function Gbc { git checkout -b @args }
function Gbd { git checkout --detach @args }
function Gbn { git branch --no-contains @args }
function Gbm { git branch --move @args }
function GbM { git branch --move --force @args }
function GbR { git branch --force @args }
function GbG { git-branch-remote-tracking gone | ForEach-Object { git branch --delete --force $_ } }

# Commit (c)
function Gc { git commit @args }
function Gca { git commit --verbose --all @args }
function GcA { git commit --verbose --patch @args }
function Gcm { git commit --message @args }
function Gco { git checkout @args }
function GcO { git checkout --patch @args }
function Gcf { git commit --amend --reuse-message HEAD @args }
function GcF { git commit --verbose --amend @args }
function Gcp { git cherry-pick @args }
function GcP { git cherry-pick --no-commit @args }
function Gcr { git revert @args }
function GcR { git reset "HEAD^" @args }
function Gcs { git show --pretty=format:"$env:_git_log_fuller_format" @args }
function GcS { git commit --verbose -S @args }
function Gcu { git commit --fixup @args }
function GcU { git commit --squash @args }
function Gcv { git verify-commit @args }

# Conflict (C)
function GCl { git --no-pager diff --name-only --diff-filter=U @args }
function GCa { git add @(GCl) }
function GCe { git mergetool @(GCl) }
function GCo { git checkout --ours -- @args }
function GCO { GCo @(GCl) }
function GCt { git checkout --theirs -- @args }
function GCT { GCt @(GCl) }

# Data (d)
function Gd { git ls-files @args }
function Gdc { git ls-files --cached @args }
function Gdx { git ls-files --deleted @args }
function Gdm { git ls-files --modified @args }
function Gdu { git ls-files --other --exclude-standard @args }
function Gdk { git ls-files --killed @args }
function Gdi { git status --porcelain --ignored=matching | Select-String '^!! ' | ForEach-Object { $_.Line -replace '^!! ', '' } }
function GdI { git ls-files --ignored --exclude-per-directory=.gitignore --cached @args }

# Fetch (f)
function Gf { git fetch @args }
function Gfa { git fetch --all @args }
function Gfp { git fetch --all --prune @args }
function Gfc { git clone @args }
function Gfm { git pull --no-rebase @args }
function Gfr { git pull --rebase @args }
function Gfu { git pull --ff-only --all --prune @args }

# Grep (g)
function Gg { git grep @args }
function Ggi { git grep --ignore-case @args }
function Ggl { git grep --files-with-matches @args }
function GgL { git grep --files-without-match @args }
function Ggv { git grep --invert-match @args }
function Ggw { git grep --word-regexp @args }

# Help (h)
function Gh { git help @args }
function Ghw { git help --web @args }

# Index (i)
function Gia { git add --verbose @args }
function GiA { git add --patch @args }
function Giu { git add --verbose --update @args }
function GiU { git add --verbose --all @args }
function Gid { git diff --no-ext-diff --cached @args }
function GiD { git diff --no-ext-diff --cached --word-diff @args }
function Gir { git reset @args }
function GiR { git reset --patch @args }
function Gix { git rm --cached -r @args }
function GiX { git rm --cached -rf @args }

# Log (l)
function Gl { git log --date-order --pretty=format:"$env:_git_log_fuller_format" @args }
function Gls { git log --date-order --stat --pretty=format:"$env:_git_log_fuller_format" @args }
function Gld { git log --date-order --stat --patch --pretty=format:"$env:_git_log_fuller_format" @args }
function Glf { git log --date-order --stat --patch --follow --pretty=format:"$env:_git_log_fuller_format" @args }
function Glo { git log --date-order --pretty=format:"$env:_git_log_oneline_format" @args }
function GlO { git log --date-order --pretty=format:"$env:_git_log_oneline_medium_format" @args }
function Glg { git log --date-order --graph --pretty=format:"$env:_git_log_oneline_format" @args }
function GlG { git log --date-order --graph --pretty=format:"$env:_git_log_oneline_medium_format" @args }
function Glv { git log --date-order --show-signature --pretty=format:"$env:_git_log_fuller_format" @args }
function Glc { git shortlog --summary --numbered @args }
function Glr { git reflog @args }

# Merge (m)
function Gm { git merge @args }
function Gma { git merge --abort @args }
function Gmc { git merge --continue @args }
function GmC { git merge --no-commit @args }
function GmF { git merge --no-ff @args }
function Gms { git merge --squash @args }
function GmS { git merge -S @args }
function Gmv { git merge --verify-signatures @args }
function Gmt { git mergetool @args }

# Push (p)
function Gp { git push @args }
function Gpf { git push --force-with-lease @args }
function GpF { git push --force @args }
function Gpa { git push --all @args }
function GpA { git push --all; git push --tags --no-verify }
function Gpt { git push --tags @args }
function Gpc { git push --set-upstream origin "$(git-branch-current 2>$null)" }
function Gpp { git pull origin "$(git-branch-current 2>$null)"; git push origin "$(git-branch-current 2>$null)" }

# Rebase (r)
function Gr { git rebase @args }
function Gra { git rebase --abort @args }
function Grc { git rebase --continue @args }
function Gri { git rebase --interactive --autosquash @args }
function Grs { git rebase --skip @args }
function GrS { git rebase --exec "git commit --amend --no-edit --no-verify -S" @args }

# Remote (R)
function GR { git remote @args }
function GRl { git remote --verbose @args }
function GRa { git remote add @args }
function GRx { git remote rm @args }
function GRm { git remote rename @args }
function GRu { git remote update @args }
function GRp { git remote prune @args }
function GRs { git remote show @args }
function GRS { git remote set-url @args }

# Stash (s)
function Gs { git stash @args }
function Gsa { git stash apply @args }
function Gsx { git stash drop @args }
function GsX { git-stash-clear-interactive @args }
function Gsl { git stash list @args }
function Gsd { git stash show --patch --stat @args }
function Gsp { git stash pop @args }
function Gsr { git-stash-recover @args }
function Gss { git stash save --include-untracked @args }
function GsS { git stash save --patch --no-keep-index @args }
function Gsw { git stash save --include-untracked --keep-index @args }
function Gsi { git stash push --staged @args } # requires Git 2.35
function Gsu { git stash show --patch | git apply --reverse @args }

# Submodule (S)
function GS { git submodule @args }
function GSa { git submodule add @args }
function GSf { git submodule foreach @args }
function GSi { git submodule init @args }
function GSI { git submodule update --init --recursive @args }
function GSl { git submodule status @args }
function GSm { git-submodule-move @args }
function GSs { git submodule sync @args }
function GSu { git submodule update --remote @args }
function GSx { git-submodule-remove @args }

# Tag (t)
function Gt { git tag @args }
function Gtl { git tag --list --sort=-committerdate @args }
function Gts { git tag --sign @args }
function Gtv { git verify-tag @args }
function Gtx { git tag --delete @args }

# Main working tree (w)
function Gws { git status --short --branch @args }
function GwS { git status @args }
function Gwd { git diff --no-ext-diff @args }
function GwD { git diff --no-ext-diff --word-diff @args }
function Gwr { git reset --soft @args }
function GwR { git reset --hard @args }
function Gwc { git clean --dry-run @args }
function GwC { git clean -d --force @args }
function Gwm { git mv @args }
function GwM { git mv -f @args }
function Gwx { git rm -r @args }
function GwX { git rm -rf @args }

# Working trees (W)
function GW { git worktree @args }
function GWa { git worktree add @args }
function GWl { git worktree list @args }
function GWm { git worktree move @args }
function GWp { git worktree prune @args }
function GWx { git worktree remove @args }
function GWX { git worktree remove --force @args }

# Switch (y)
function Gy { git switch @args } # requires Git 2.23
function Gyc { git switch --create @args }
function Gyd { git switch --detach @args }

# Misc
function G.. { Set-Location (git rev-parse --show-toplevel 2>$null) }
function G? { git-alias-lookup $env:gmodule_home @args }
