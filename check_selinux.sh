#!/bin/bash

# Copyright © 2017 Mohamed El Morabity <melmorabity@fedoraproject.com>
#
# This module is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This software is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.


PLUGIN_FILENAME=${0##*/}
PLUGIN_DIR=$(dirname "$0")

. $PLUGIN_DIR/utils.sh

SELINUX_MODES=("enforcing" "permissive" "disabled")

ERROR_STATE=$STATE_CRITICAL
ERROR_STATE_LABEL="ERROR"


usage() {
    cat <<EOF
Usage: $PLUGIN_FILENAME [-h] [-w] SELINUX_MODE

Optional arguments:
  -h, --help             Show this help message and exit
  -w, --warning          Exit warning, instead of critical by default, if
                         current SELinux status doesn't match expected one

Required arguments:
  SELINUX_MODE           Expected SELinux mode (allowed values: ${SELINUX_MODES[@]})

EOF
}


parse_arguments() {
    local args=( "$@" )

    local temp
    temp=$(getopt --name "$PLUGIN_FILENAME"  --options "hw" --longoptions "help,warning" -- "${args[@]:-}")
    eval set -- "$temp"

    while true; do
	case "$1" in
	    -w | --warning)
		ERROR_STATE=$STATE_WARNING
		ERROR_STATE_LABEL="WARNING"
		shift
		;;
	    --)
		shift
		break
		;;
	    *)
		usage
		exit $STATE_UNKNOWN
		;;
	esac
    done

    if [[ $# -ne 1 ]]; then
	usage
	exit $STATE_UNKNOWN
    fi

    EXPECTED_SELINUX_MODE=${1,,}
    if ! [[ "${SELINUX_MODES[@]}" =~ (^|[[:space:]])$EXPECTED_SELINUX_MODE($|[[:space:]]) ]]; then
	usage
	exit $STATE_UNKNOWN
    fi
}


check_selinux_mode() {
    local selinux_mode
    selinux_mode=$(getenforce)
    if [ $? -ne 0 ]; then
	echo "ERROR: unable to retrieve SELinux mode"
	exit $STATE_CRITICAL
    fi

    if [[ "${selinux_mode,,}" != $EXPECTED_SELINUX_MODE ]]; then
	echo "$ERROR_STATE_LABEL: SELinux is not $EXPECTED_SELINUX_MODE (currently ${selinux_mode,,})"
	exit $ERROR_STATE
    fi

    echo "OK: SELinux is $EXPECTED_SELINUX_MODE"
    exit $STATE_OK
}


parse_arguments "$@"
check_selinux_mode
