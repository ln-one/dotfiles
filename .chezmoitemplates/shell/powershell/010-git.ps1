# ========================================
# Git Aliases (PowerShell version, prefix: G)
# ========================================

# Helper for running git with arguments
function G { git @args }

# Branch (b)
Set-Alias Gb 'git branch'
Set-Alias Gbl 'git branch'
Set-Alias GbL 'git branch'
Set-Alias Gbs 'git show-branch'
Set-Alias GbS 'git show-branch'
Set-Alias Gbu 'git branch'
Set-Alias Gbx 'git-branch-delete-interactive'
Set-Alias GbX 'git-branch-delete-interactive'
# 其余带参数的保留为函数
function Gbc { git checkout -b @args }
function Gbd { git checkout --detach @args }
function Gbn { git branch --no-contains @args }
function Gbm { git branch --move @args }
function GbM { git branch --move --force @args }
function GbR { git branch --force @args }
function GbG { git-branch-remote-tracking gone | ForEach-Object { git branch --delete --force $_ } }

# Commit (c)
Set-Alias Gc 'git commit'
Set-Alias Gco 'git checkout'
Set-Alias Gcp 'git cherry-pick'
Set-Alias Gcr 'git revert'
Set-Alias Gcv 'git verify-commit'
function Gca { git commit --verbose --all @args }
function GcA { git commit --verbose --patch @args }
function Gcm { git commit --message @args }
function GcO { git checkout --patch @args }
function Gcf { git commit --amend --reuse-message HEAD @args }
function GcF { git commit --verbose --amend @args }
function GcP { git cherry-pick --no-commit @args }
function GcR { git reset "HEAD^" @args }
function Gcs { git show --pretty=format:"$env:_git_log_fuller_format" @args }
function GcS { git commit --verbose -S @args }
function Gcu { git commit --fixup @args }
function GcU { git commit --squash @args }

# Conflict (C)
function GCl { git --no-pager diff --name-only --diff-filter=U @args }
function GCa { git add @(GCl) }
function GCe { git mergetool @(GCl) }
function GCo { git checkout --ours -- @args }
function GCO { GCo @(GCl) }
function GCt { git checkout --theirs -- @args }
function GCT { GCt @(GCl) }

# Data (d)
Set-Alias Gd 'git ls-files'
Set-Alias Gdc 'git ls-files'
Set-Alias Gdx 'git ls-files'
Set-Alias Gdm 'git ls-files'
Set-Alias Gdu 'git ls-files'
Set-Alias Gdk 'git ls-files'
function Gdi { git status --porcelain --ignored=matching | Select-String '^!! ' | ForEach-Object { $_.Line -replace '^!! ', '' } }
function GdI { git ls-files --ignored --exclude-per-directory=.gitignore --cached @args }

# Fetch (f)
Set-Alias Gf 'git fetch'
Set-Alias Gfa 'git fetch'
Set-Alias Gfp 'git fetch'
Set-Alias Gfc 'git clone'
function Gfm { git pull --no-rebase @args }
function Gfr { git pull --rebase @args }
function Gfu { git pull --ff-only --all --prune @args }

# Grep (g)
Set-Alias Gg 'git grep'
function Ggi { git grep --ignore-case @args }
function Ggl { git grep --files-with-matches @args }
function GgL { git grep --files-without-match @args }
function Ggv { git grep --invert-match @args }
function Ggw { git grep --word-regexp @args }

# Help (h)
Set-Alias Gh 'git help'
function Ghw { git help --web @args }

# Index (i)
Set-Alias Gia 'git add'
Set-Alias GiA 'git add'
Set-Alias Giu 'git add'
Set-Alias GiU 'git add'
Set-Alias Gir 'git reset'
function Gid { git diff --no-ext-diff --cached @args }
function GiD { git diff --no-ext-diff --cached --word-diff @args }
function GiR { git reset --patch @args }
function Gix { git rm --cached -r @args }
function GiX { git rm --cached -rf @args }

# Log (l)
Set-Alias Glc 'git shortlog'
Set-Alias Glr 'git reflog'
function Gl { git log --date-order --pretty=format:"$env:_git_log_fuller_format" @args }
function Gls { git log --date-order --stat --pretty=format:"$env:_git_log_fuller_format" @args }
function Gld { git log --date-order --stat --patch --pretty=format:"$env:_git_log_fuller_format" @args }
function Glf { git log --date-order --stat --patch --follow --pretty=format:"$env:_git_log_fuller_format" @args }
function Glo { git log --date-order --pretty=format:"$env:_git_log_oneline_format" @args }
function GlO { git log --date-order --pretty=format:"$env:_git_log_oneline_medium_format" @args }
function Glg { git log --date-order --graph --pretty=format:"$env:_git_log_oneline_format" @args }
function GlG { git log --date-order --graph --pretty=format:"$env:_git_log_oneline_medium_format" @args }
function Glv { git log --date-order --show-signature --pretty=format:"$env:_git_log_fuller_format" @args }

# Merge (m)
Set-Alias Gm 'git merge'
Set-Alias Gmt 'git mergetool'
function Gma { git merge --abort @args }
function Gmc { git merge --continue @args }
function GmC { git merge --no-commit @args }
function GmF { git merge --no-ff @args }
function Gms { git merge --squash @args }
function GmS { git merge -S @args }
function Gmv { git merge --verify-signatures @args }

# Push (p)
Set-Alias Gp 'git push'
Set-Alias Gpa 'git push'
Set-Alias Gpt 'git push'
function Gpf { git push --force-with-lease @args }
function GpF { git push --force @args }
function GpA { git push --all; git push --tags --no-verify }
function Gpc { git push --set-upstream origin "$(git-branch-current 2>$null)" }
function Gpp { git pull origin "$(git-branch-current 2>$null)"; git push origin "$(git-branch-current 2>$null)" }

# Rebase (r)
Set-Alias Gr 'git rebase'
function Gra { git rebase --abort @args }
function Grc { git rebase --continue @args }
function Gri { git rebase --interactive --autosquash @args }
function Grs { git rebase --skip @args }
function GrS { git rebase --exec "git commit --amend --no-edit --no-verify -S" @args }

# Remote (R)
Set-Alias GR 'git remote'
Set-Alias GRl 'git remote'
Set-Alias GRa 'git remote'
Set-Alias GRx 'git remote'
Set-Alias GRm 'git remote'
Set-Alias GRu 'git remote'
Set-Alias GRp 'git remote'
Set-Alias GRs 'git remote'
Set-Alias GRS 'git remote'

# Stash (s)
Set-Alias Gs 'git stash'
Set-Alias Gsa 'git stash'
Set-Alias Gsx 'git stash'
Set-Alias Gsl 'git stash'
Set-Alias Gsd 'git stash'
Set-Alias Gsp 'git stash'
function GsX { git-stash-clear-interactive @args }
function Gsr { git-stash-recover @args }
function Gss { git stash save --include-untracked @args }
function GsS { git stash save --patch --no-keep-index @args }
function Gsw { git stash save --include-untracked --keep-index @args }
function Gsi { git stash push --staged @args } # requires Git 2.35
function Gsu { git stash show --patch | git apply --reverse @args }

# Submodule (S)
Set-Alias GS 'git submodule'
Set-Alias GSa 'git submodule'
Set-Alias GSf 'git submodule'
Set-Alias GSi 'git submodule'
Set-Alias GSI 'git submodule'
Set-Alias GSl 'git submodule'
Set-Alias GSm 'git-submodule-move'
Set-Alias GSs 'git submodule'
Set-Alias GSu 'git submodule'
Set-Alias GSx 'git-submodule-remove'

# Tag (t)
Set-Alias Gt 'git tag'
Set-Alias Gtl 'git tag'
Set-Alias Gts 'git tag'
Set-Alias Gtv 'git verify-tag'
Set-Alias Gtx 'git tag'

# Main working tree (w)
Set-Alias Gws 'git status'
Set-Alias GwS 'git status'
Set-Alias Gwd 'git diff'
Set-Alias GwD 'git diff'
Set-Alias Gwr 'git reset'
Set-Alias GwR 'git reset'
Set-Alias Gwc 'git clean'
Set-Alias GwC 'git clean'
Set-Alias Gwm 'git mv'
Set-Alias GwM 'git mv'
Set-Alias Gwx 'git rm'
Set-Alias GwX 'git rm'

# Working trees (W)
Set-Alias GW 'git worktree'
Set-Alias GWa 'git worktree'
Set-Alias GWl 'git worktree'
Set-Alias GWm 'git worktree'
Set-Alias GWp 'git worktree'
Set-Alias GWx 'git worktree'
Set-Alias GWX 'git worktree'

# Switch (y)
Set-Alias Gy 'git switch'
Set-Alias Gyc 'git switch'
Set-Alias Gyd 'git switch'

# Misc
function G.. { Set-Location (git rev-parse --show-toplevel 2>$null) }
function G? { git-alias-lookup $env:gmodule_home @args }
