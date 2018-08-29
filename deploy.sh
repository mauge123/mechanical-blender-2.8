#! /bin/bash
# This is de deploy script for mechanical blender 2.8 series
# This file is inspired with install_deps.sh file from blender sources.


#####  Patches definition #####

PATCHES=(
mblender-0001  # Adds texts to Splash Screen
)

SOURCE=$(pwd)"/blender"
GIT_URL="git://git.blender.org/blender.git"
GIT_BRANCH=""
GIT_HASH="6fa7fa6671c9e7cf9baad54b0f0861755b43f2b1"
PATCHES_DIR=$(pwd)"/patches"
NO_BUILD=false;


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

FATAL_ERROR () {
    echo -e "\n${BRIGHT}${RED}FATAL ERROR ${NORMAL}${RED}$@${NORMAL}\n"
    exit 1
}

WARNING() {
  echo -e "${BRIGHT}${YELLOW}WARNING! ${NORMAL}${YELLOW}$@${NORMAL}\n"
}

INFO() {
    echo -e "${GREEN}$@${NORMAL}\n"
}

PRINT() {
    echo "$@";
}

##### Global Bars #####

ARGUMENTS_INFO="
    --git-branch
    --git-hash
    --git-url
        Url of blender repository. Defaults to bf blender repository: $GIT_URL_BF_BLENDER
    -h, --help
         Show this message and exit.
    --no-build
        Only apply patches
    -s, --source
        Path where blender will be download. Defaults to ./blender
"
        
COMMON_INFO="
Mechanical Blender is a project that tries to bring \
cad utils to BF blender focused on CAD works. Visit http://www.mechanicalblender.org for more references
Use --help for usage"

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
--long git-branch:,help,no-build,source: \
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
PWD=$(pwd)


##### Args Handling #####

# Finish parsing the commandline args.
eval set -- "$ARGS"
while true; do
  case $1 in
    --git-branch)
        GIT_BRANCH=$2; shift; shift; continue
    ;;
    --git-hash)
        GIT_HASH=$2; shift; shift; continue
    ;;
    --git-url)
        GIT_URL=$2;shift; shift; continue
    ;;
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
    --patches-dir)
        PATCH_DIR=$2; shift; shift; continue
    ;;
    -s|--source)
        SOURCE=$2;shift; shift; continue
    ;;
    --)
      # no more arguments to parse
      break
    ;;
    *)
      FATAL_ERROR "parameter $1!"
    ;;
  esac
done


deploy() {
    PRINT $COMMON_INFO 
    
    if [ -z "$GIT" ]; then
        FATAL_ERROR "GIT is not found, and necessary to download blender"
    fi
    
    if [ ! -d $SOURCE ]; then
        INFO "creating $SOURCE directory"
        $(mkdir $SOURCE)
    fi
    
    if [ ! -d $SOURCE ]; then
        FATAL_ERROR "$SOURCE is and invalid path"
    fi
    
    PRINT "Source dir is $SOURCE"
    PRINT "git path is $GIT_URL"  
    PRINT "git branch is $GIT_BRANCH"
    PRINT "git hash is $GIT_HASH"
    
    if [ -z "$(ls -A $SOURCE)" ]; then
        INFO "Source dir is empty cloning source dir"
        $(git clone $GIT_URL $SOURCE)
    fi
    
    if [ "$GIT_BRANCH" ]; then
        if ["$GIT_HASH" ]; then
            FATAL_ERROR "git-hash and git-url can not be set at same time"
        else
            R=$(git --git-dir $SOURCE/.git  checkout $GIT_BRANCH)
            GIT_HASH=$(git --git-dir $SOURCE/.git log -1 --format="%H")
        fi
    fi
    
    if [ "$GIT_HASH" ]; then
        R=$(git --git-dir $SOURCE/.git  checkout $GIT_HASH)
    fi
    
    # TODO: check status of working copy
    # this one is not working properly from another source
    # if [ ! -z "$(git --git-dir $SOURCE/.git status --porcelain)" ]; then 
    #   WARNING "Not clean working copy!"
    # fi
    
    for p in "${PATCHES[@]}"; do
        PRINT "APPLYING PATCH $p"
        p="$PATCHES_DIR"/"$p".diff
        R=$(patch -d $SOURCE -p1 < $p) 
    done
    
}


#### "Main" ####
deploy

exit 0

