# nagios-plugins-selinux

Nagios plugin to check the current mode of SELinux.


## Authors

Mohamed El Morabity <melmorabity -(at)- fedoraproject.org>

## Usage

    check_selinux.sh [-h|--help]
    check_selinux.sh [-w|--warning] enforcing|permissive|disabled

## Examples

    # setenforce 1

    $ ./check_selinux.sh enforcing
    OK: SELinux is enforcing

    # setenforce 0

    $ ./check_selinux.sh enforcing
    ERROR: SELinux is not enforcing (currently permissive)

    $ ./check_selinux.sh --warning enforcing
    WARNING: SELinux is not enforcing (currently permissive)
