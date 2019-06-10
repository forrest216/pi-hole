#!/usr/bin/env bash
# Pi-hole: A black hole for Internet advertisements
# (c) 2017-2019 Pi-hole, LLC (https://pi-hole.net)
# Network-wide ad blocking via your own hardware.
#
# Installs Pi-hole
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.

# pi-hole.net/donate
#
# Install with this command (from your Linux machine):
#
# curl -sSL https://install.pi-hole.net | bash

# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# We do not want users to end up with a partially working install, so we exit the script
# instead of continuing the installation with something broken
set -e

########## VARIABLES

# Set these values so the installer can run in color
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
OVER="\\r\\033[K"

# Used to execute commands under the root user. This is set by the root_check
# function
SUDO=

# The type of package which this system uses. Either DEB or RPM. This is set by
# the detected_package_type function
PACKAGE_TYPE=

# The install command to use when installing the Pi-hole package. This is set by
# the detected_package_type function
INSTALL_COMMAND=

######### END VARIABLES

# A simple function that just echoes out our logo in ASCII format
# This lets users know that it is a Pi-hole, LLC product
show_ascii_berry() {
  echo -e "
        ${COL_LIGHT_GREEN}.;;,.
        .ccccc:,.
         :cccclll:.      ..,,
          :ccccclll.   ;ooodc
           'ccll:;ll .oooodc
             .;cll.;;looo:.
                 ${COL_LIGHT_RED}.. ','.
                .',,,,,,'.
              .',,,,,,,,,,.
            .',,,,,,,,,,,,....
          ....''',,,,,,,'.......
        .........  ....  .........
        ..........      ..........
        ..........      ..........
        .........  ....  .........
          ........,,,,,,,'......
            ....',,,,,,,,,,,,.
               .',,,,,,,,,'.
                .',,,,,,'.
                  ..'''.${COL_NC}
"
}

# Check if the command exists
#
# Args:
# 1. The name of the command
is_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check for root access. If this function completes, future commands can be run
# under root by prepending the SUDO variable
root_check() {
    # Must be root to install
    local str="Root user check"
    printf "\\n"

    if [[ "${EUID}" -eq 0 ]]; then
        # They are root
        printf "  %b %s\\n" "${TICK}" "${str}"

        # No extra commands needed to run as root
        SUDO=""
    # Otherwise,
    else
        # They do not have enough privileges, so let the user know
        printf "  %b %s\\n" "${CROSS}" "${str}"
        printf "  %b %bScript called with non-root privileges%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      The Pi-hole requires elevated privileges to install and run\\n"
        printf "      Please check the installer for any concerns regarding this requirement\\n"
        printf "      Make sure to download this script from a trusted source\\n\\n"

        if is_command sudo; then
            printf "  %b Sudo utility check\\n" "${TICK}"
            SUDO="sudo"

            printf "  %b Authenticating the current user..." "${INFO}"

            "${SUDO}" :

            printf "  %b Authenticated" "${TICK}"
        # Otherwise,
        else
            # Let them know they need to run it as root
            printf "  %b Sudo utility check\\n" "${CROSS}"
            printf "  %b Root access is needed to install Pi-hole\\n\\n" "${INFO}"
            printf "  %b %bPlease re-run this installer as root%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
        fi
    fi
}

# Detect if this is a DEB or RPM based system, and get the correct install
# command.
detect_package_type() {
    printf "  %b Detecting system package type" "${PACKAGE_TYPE}"

    if is_command apt-get; then
        PACKAGE_TYPE=DEB
        INSTALL_COMMAND="apt-get install -y pihole"
    elif is_command rpm; then
        PACKAGE_TYPE=RPM

        # Then check if dnf or yum is the package manager
        if is_command dnf; then
            INSTALL_COMMAND="dnf install -y pihole"
        else
            INSTALL_COMMAND="yum install -y pihole"
        fi
    else
        printf "  %b Failed to detect package type" "${CROSS}"
        exit 1
    fi

    printf "  %b Detected %s" "${TICK}" "${PACKAGE_TYPE}"
}

# Install the package repository
# TODO: Change to use release repo
install_repo() {
    printf "  %b Installing package repository" "${INFO}"

    case "${PACKAGE_TYPE}" in
        DEB)
            curl -1sLf 'https://dl.cloudsmith.io/public/pihole/testing/cfg/setup/bash.deb.sh' \
                | "${SUDO}" bash
            ;;
        RPM)
            curl -1sLf 'https://dl.cloudsmith.io/public/pihole/testing/cfg/setup/bash.rpm.sh' \
                | "${SUDO}" bash
            ;;
        *)
            printf "  %b Failed to install repository: Unknown package type" "${CROSS}"
            exit 1
            ;;
    esac
}

# Install the Pi-hole packages and dependencies
install_packages() {
    printf "  %b Installing Pi-hole packages" "${INFO}"

    "${SUDO}" "${INSTALL_COMMAND}"

    printf "  %b Finished installing packages" "${TICK}"
}

main() {
    # Show the Pi-hole logo so people know it's genuine since the logo and name
    # are trademarked
    show_ascii_berry
    root_check
    detect_package_type
    install_repo
    install_packages
}

main
