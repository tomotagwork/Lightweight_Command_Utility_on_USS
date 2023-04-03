# Lightweight Command Utility on USS

## 概要
USS(Unix System Service) のシェルから各種z/OS操作を行うためのスクリプト群です。REXX、Shell Scriptで実装されています。

詳細は以下のQiita記事をご参照ください。

https://qiita.com/tomotagwork/items/bb7f9592658389d2c5c6


## セットアップ

### (1) スクリプト群の配置
USS上にRocket Gitがセットアップされている場合は、USS上に直接クローンしてください。

`git clone https://github.com/tomotagwork/Lightweight_Command_Utility_on_USS.git`


もしくはPC経由で当リポジトリに含まれるスクリプト(rex, sh)をUSS上の同一ディレクトリ下に配置すればOKです。

ここでは、`/u/user01/Lightweight_Command_Utility_on_USS/Util/` 以下にファイルが展開されているものとします。

### (2) 環境変数設定

`util_env.sh` にPATHの設定とAliasの設定を行うスクリプトを用意しています。ここでは 当ツールのパスをUtilDirという環境変数で指定する想定になっているので、シェルに対して以下のように環境変数の設定を行います。

```
export UtilDir=/u/user01/Lightweight_Command_Utility_on_USS/Util
. ${UtilDir}/util_env.sh
```

ユーザーの `.profile`に上の設定を仕込んでおくとよいでしょう。

---

## 補足: Rocket Git on z/OS について

### git client用環境変数設定例

```
GIT_ROOT=/usr/lpp/Rocket/rsusr/ported

export GIT_SHELL=$GIT_ROOT/bin/bash
export GIT_EXEC_PATH=$GIT_ROOT/libexec/git-core
export GIT_TEMPLATE_DIR=$GIT_ROOT/share/git-core/templates

export PATH=$GIT_ROOT/bin:$PATH
export MANPATH=$MANPATH:$GIT_ROOT/man
export PERL5LIB=$PERL5LIB:$GIT_ROOT/lib/perl5

# These enable enhanced ASCII support
export _BPXK_AUTOCVT=ALL
export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt

# optional (do once): set git editor to create comments on encoding ISO8859-1
# git config --global core.editor "/bin/vi -W filecodeset=ISO8859-1"
```

参考: 

[Rocket Forum](https://community.rocketsoftware.com/forums/forum-home/digestviewer/viewthread?GroupId=79&MID=2509&CommunityKey=1e694975-142d-4f2d-9b52-0e37e225db41&tab=digestviewer)

[DBB Document](https://www.ibm.com/docs/en/dbb/2.0.0?topic=SS6T76_2.0.0/setup_git_on_uss.htm)


### Configファイル設定例

.gitconfig

```
[user]
        name = user01
        email = user01@example.com
[http]
        proxy = socks5h://xx.xx.xx.xx:nnnnn
        sslverify = false
[credential]
        helper = cache --timeout=3600
```

