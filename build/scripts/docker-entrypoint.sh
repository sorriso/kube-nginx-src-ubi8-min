#!/bin/sh
# vim:sw=4:ts=4:et

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
export USER_NAME=nginx
export HOME=/var/lib/nginx

envsubst < /passwd.template > /tmp/passwd

export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group


if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo  "NGINX_ENTRYPOINT_QUIET_LOGS true"
    exec 3>&1
else
    echo  "NGINX_ENTRYPOINT_QUIET_LOGS false"
    exec 3>/dev/null
fi

if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

        echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi

echo >&3 "cmd : $@"

exec "$@"
