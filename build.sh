#!/bin/bash

COLOR_PROGRESS='\e[1;34m'
COLOR_FAIL='\e[1;31m'
COLOR_RESET='\e[0m' # No Color

function fail {
    echo -e "${COLOR_FAIL}ERROR: $1${COLOR_RESET}"
    exit 1
}

function error {
    echo -e "${COLOR_FAIL}ERROR: $1${COLOR_RESET}"
}

function progress {
    echo -e "${COLOR_PROGRESS}$1..${COLOR_RESET}"
}

echo "  ________  __  ____  _   _ "
echo " |___  /  \/  |/ __ \| \ | |"
echo "    / /| \  / | |  | |  \| |"
echo "   / / | |\/| | |  | | . \` |"
echo "  / /__| |  | | |__| | |\  |"
echo " /_____|_|  |_|\____/|_| \_|"

progress 'Checking prerequisites'
git --version > /dev/null || fail "git is required"

MAVEN_VERSION=$(mvn --version | head -n 1 | grep -o '3\.')
[ "v$MAVEN_VERSION" = "v3." ] || fail "Maven 3 is required"

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | grep -o '1\.8')
[ "v$JAVA_VERSION" = "v1.8" ] || fail "Java 1.8 is required"

PYTHON_VERSION=$(python --version 2>&1 | grep -o '2\.7')
[ "v$PYTHON_VERSION" = "v2.7" ] || fail "Python 2.7 is required"

progress 'Building Controller'
(cd zmon-controller && mvn clean package && docker build -t zmon-controller . && docker save -o zmon-controller.tar zmon-controller)

progress 'Building Scheduler'
(cd zmon-scheduler && docker build -t zmon-scheduler . && docker save -o zmon-scheduler.tar zmon-scheduler)

progress 'Building Worker'
(cd zmon-worker && docker build -t zmon-worker . && docker save -o zmon-worker.tar zmon-worker)