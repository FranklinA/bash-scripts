#!/bin/bash

##################################
## Utilities for git and mercurial
##################################


##
## Common to git and mercurial
##


function scm_filter {
  while read line ;do
    s="$( echo $line | cut -d' ' -f 1 )"
    f="$( echo $line | cut -d' ' -f 2 )"
    # echo ":::$s:::$f:::"
    # if [ "$s" == "M" -o "$s" == "A" -o "$s" == "?" ] ;then
    if [ -f "$f" ] ;then
      echo $f
    fi
  done
}


function scm_modified {
  if [ -d .hg ] ;then
    hg status | scm_filter
  elif [ -d .git ] ;then
    git status --porcelain | scm_filter
  fi
}


function scm_changeset {

  here=$( pwd )
  name=$( basename $here )
  dir=~/backup/${SUDO_USER:=${USER}}/changesets${here}

  mkdir -p $dir

  now=$(date +%Y%m%d_%H%M%S )
  file=${dir}/${now}-${name}.tgz

  scm_modified | xargs tar cpzf $file && echo $file
}


##
## git
##


function git_origin_ssh {
  protocol=$(git config --get remote.origin.url | cut -d/ -f1)
  if [ X${protocol} == "Xhttp:" -o X${protocol} == "Xhttps:" ] ;then
    provider=$(git config --get remote.origin.url | cut -d/ -f3 | cut -d@ -f2)
    team=$(git config --get remote.origin.url | cut -d/ -f4)
    prj=$(git config --get remote.origin.url | cut -d/ -f5)
    git remote remove origin
    # workaround https://bitbucket.org/site/master/issues/5154/someone-has-already-registered-that-ssh
    company=$(fgrep Host ~/.ssh/config | fgrep -v Hostname | cut -d' ' -f2)
    if [ X${company} != "X" -a X${provider} == "Xbitbucket.org" -a -f ~/.ssh/id_rsa_${team} ] ;then
      provider=${company}
    fi
    git remote add origin git@${provider}:${team}/${prj}
  fi
}


function git_clone {
    module=$1
    url=$2
    echo "[ clone $module ]"
    if [ ! -d $HOME/workspace ] ;then
        mkdir -p $HOME/workspace
    fi
    pushd $HOME/workspace
    if [ ! -d ${module} ] ;then
        pushd $HOME/workspace
        git clone ${url} ${module}
        if [ $? != 0 ] ; then popd; popd; return 1 ;fi
        popd
    else
        pushd $HOME/workspace/${module}
        git pull $url
        if [ $? != 0 ] ; then popd; popd; return 1 ;fi
        popd
    fi
    git status
    popd
}


function git_switch {
    module=$1
    tag=$2
    echo "[ checkout $module ]"
    if [ -d $HOME/workspace/${module} ] ;then
        pushd $HOME/workspace/${module}
	git clean -d -x -f -f
        if [ $? != 0 ] ; then popd; return 1 ;fi
        git checkout tags/${tag} --force
        if [ $? != 0 ] ; then popd; return 1 ;fi
	git submodule update --init --force --recursive
        if [ $? != 0 ] ; then popd; return 1 ;fi
	git clean -d -x -f -f
        if [ $? != 0 ] ; then popd; return 1 ;fi
        git status
        popd
    fi
}