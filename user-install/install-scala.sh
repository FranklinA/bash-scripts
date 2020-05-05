#!/bin/bash


function install_scala_binaries {
  local version=${1:-"$SCALA_VERSION"}
  local version=${version:-"2.12.10"}
  local major=$( echo ${version} | cut -d. -f 1-2 )

  if [[ $version =~ ^(0\.).* ]] ;then
    local file=dotty-${version}.tar.gz
    local url=https://github.com/lampepfl/dotty/releases/download/${version}/${file}
    local folder=dotty-${version}
    local symlink=dotty-${major}
  else
    local file=scala-${version}.tgz
    local url=http://downloads.lightbend.com/scala/${version}/${file}
    local folder=scala-${version}
    local symlink=scala-${major}
  fi
       
  local tools="${TOOLS_HOME:=$HOME/tools}"
  local Software="${SOFTWARE:=/mnt/omv/Software}"

  [[ ! -d "${DOWNLOADS}" ]] && mkdir -p "${DOWNLOADS}"
  [[ ! -d $tools ]] && mkdir -p $tools

  local archive=""
  if [[ -f "${Software}"/Linux/${file} ]] ;then
    local archive=${Software}/Linux/${file}
  elif [[ -f "${DOWNLOADS}"/${file} ]] ;then
    local archive="${DOWNLOADS}"/${file}
  fi
  if [[ -z ${archive} ]] ;then
    local archive="${DOWNLOADS}"/${file}
    wget "$url" -O "${archive}"
  fi

  if [ ! -d "${tools}"/${folder} ] ;then
    tar -C "${tools}" -xpf ${archive}
  fi
  
  if [ ! -z ${symlink} ] ;then
    if [ -L "${tools}"/${symlink} ] ;then rm "${tools}"/${symlink} ;fi
    ln -s ${folder} "${tools}"/${symlink}
  fi
}

function install_scala_api {
  local version=${1:-"$SCALA_VERSION"}
  local version=${version:-"2.12.10"}
  local major=$( echo ${version} | cut -d. -f 1-2 )

  if [[ $version =~ ^(0\.).* ]] ;then
    echo Dotty does not provide Scala API docs yet.
    return
  fi
  
  local file=scala-docs-${version}.txz
  local url=http://downloads.lightbend.com/scala/${version}/${file}
  local folder=scala-${version}
  local symlink=scala-${major}

  local tools="${TOOLS_HOME:=$HOME/tools}"
  local Software="${SOFTWARE:=/mnt/omv/Software}"

  [[ ! -d "${DOWNLOADS}" ]] && mkdir -p "${DOWNLOADS}"
  [[ ! -d $tools ]] && mkdir -p $tools

  local archive=""
  if [[ -f "${Software}"/Linux/${file} ]] ;then
    local archive=${Software}/Linux/${file}
  elif [[ -f "${DOWNLOADS}"/${file} ]] ;then
    local archive="${DOWNLOADS}"/${file}
  fi
  if [[ -z ${archive} ]] ;then
    local archive="${DOWNLOADS}"/${file}
    wget "$url" -O "${archive}"
  fi

  if [ ! -d "${tools}"/${folder}/api ] ;then
    tar -C "${tools}" -xpf ${archive}
  fi
  
  if [ -L "${tools}"/${symlink} ] ;then rm "${tools}"/${symlink} ;fi
  ln -s ${folder} "${tools}"/${symlink}
}

function install_scala_spec {
  local version=${1:-"$SCALA_VERSION"}
  local version=${version:-"2.12.10"}
  local major=$( echo ${version} | cut -d. -f 1-2 )

  if [[ $version =~ ^(0\.).* ]] ;then
    echo Dotty does not provide a Scala spec yet.
    return
  fi
  
  local file=scala-${version}.tgz
  local url=http://downloads.lightbend.com/scala/${version}/${file}
  local folder=scala-${version}
  local symlink=scala-${major}

  local tools="${TOOLS_HOME:=$HOME/tools}"
  local Software="${SOFTWARE:=/mnt/omv/Software}"

  [[ ! -d "${DOWNLOADS}" ]] && mkdir -p "${DOWNLOADS}"
  [[ ! -d $tools ]] && mkdir -p $tools

  [[ ! -d "${tools}"/${folder}/spec ]] && mkdir -p "${tools}"/${folder}/spec
  [[ ! -f "${tools}"/${folder}/spec/index.html ]] \
    && httrack -O "${tools}"/${folder}/spec http://www.scala-lang.org/files/archive/spec/${major}

  if [ -L "${tools}"/${symlink} ] ;then rm "${tools}"/${symlink} ;fi
  ln -s ${folder} "${tools}"/${symlink}
}

function install_scala {
  self=$(readlink -f "${BASH_SOURCE[0]}"); dir=$(dirname $self)
  grep -E "^function " $self | fgrep -v "function __" | cut -d' ' -f2 | head -n -1 | while read cmd ;do
    $cmd $*
  done
}


if [ $_ != $0 ] ;then
  # echo "Script is being sourced: list all functions"
  self=$(readlink -f "${BASH_SOURCE[0]}"); dir=$(dirname $self)
  grep -E "^function " $self | fgrep -v "function __" | cut -d' ' -f2 | head -n -1
else
  # echo "Script is a subshell: execute last function"
  self=$(readlink -f "${BASH_SOURCE[0]}"); dir=$(dirname $self)
  cmd=$(grep -E "^function " $self | cut -d' ' -f2 | tail -1)
  $cmd $*
fi
