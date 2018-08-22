#! /bin/bash
# This is de deploy script for mechanical blender 2.8 series
# This file is inspired with install_deps.sh file from blender sources.

COMMANDLINE=$@

##### Generic Helpers #####

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)


ERROR() {
  echo -e "\n${BRIGHT}${RED}ERROR! ${NORMAL}${RED}$@${NORMAL}\n"
}

WARNING() {
  echo -e "${BRIGHT}${YELLOW}WARNING! ${NORMAL}${YELLOW}$@${NORMAL}\n"
}

INFO() {
  echo -e "${GREEN}$@${NORMAL}\n"
}

PRINT() {
  echo  -e "$@\n"
}


GIT_URL_BF_BLENDER="git://git.blender.org/blender.git"

##### Global Bars #####

ARGUMENTS_INFO="
    --git-url
        Url of blender repository. Defaults to bf blender repository: $GIT_URL_BF_BLENDER
    -h, --help
         Show this message and exit.
    --no-build
        Only apply patches
    -s, --source
        Path where blender will be download. Defaults to ./blender
"
        
COMMON_INFO="Mechanical Blender is a project that tries to bring \
cad utils to BF blender focused on CAD works. Visit http://www.mechanicalblender.org for more references"

USAGE="./deploy.sh [options]"

CREDITS="Jaume Bellet <mauge@bixo.org>
TMAQ <http://www.tmaq.es>
all people that have contributed to bf-blender

http://mechanicalblender.org
https://www.patreon.com/mechanicalblender
http://www.blender.org"


# Parse command line!
ARGS=$( \
getopt \
--options h,s \
--long git-url:,help,no-build,source: \
-- "$@" \
)

if [ -f /etc/debian_version ]; then
  DISTRO="DEB"
elif [ -f /etc/arch-release ]; then
  DISTRO="ARCH"
elif [ -f /etc/redhat-release -o /etc/SuSE-release ]; then
  DISTRO="RPM"
else
  DISTRO="OTHER"
fi

GIT=$(which git)

SOURCE=$(pwd)"/blender"
GIT_URL="$GIT_URL_BF_BLENDER"

NO_BUILD=false;


##### Args Handling #####

# Finish parsing the commandline args.
eval set -- "$ARGS"
while true; do
  case $1 in
    -h|--help)
      PRINT "$COMMON_INFO"
      INFO "USAGE:"
      PRINT "$USAGE"
      INFO "COMMAND LINE ARGUMENTS"
      PRINT "$ARGUMENTS_INFO"
      INFO "CREDITS"
      PRINT "$CREDITS"
      exit 0
    ;;
    --no-build)
      NO_BUILD=true; shift; continue
    ;;
    --)
      # no more arguments to parse
      break
    ;;
    *)
      ERROR "Wrong parameter! Usage:"
      PRINT "`eval _echo "$COMMON_INFO"`"
      exit 1
    ;;
  esac
done


deploy() {
    PRINT $COMMON_INFO 
    
    if [ -z "$GIT" ]; then
        ERROR "GIT is not found, and necessary to download blender"
        exit 1
    fi
    
    if [ ! -d $SOURCE ]; then
        INFO "creating $SOURCE directory"
        $(mkdir $SOURCE)
    fi
    
    if [ ! -d $SOURCE ]; then
        ERROR "$SOURCE is and invalid path"
        exit 1
    fi
    PRINT "Source dir is $SOURCE" 
    
}


#### "Main" ####
deploy

exit 0

