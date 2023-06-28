#!/bin/sh

log() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $@"
}

if [ -n "$WILDFLY_USERS" ]; then
    log "Adding users to WildFly"
    for user_settings in "$WILDFLY_USERS"; do
        IFS=":" read -r user realm password << EOF
$user_settings
EOF
        if [ -n "$user" ]; then
            if [ -z "$password" ]; then
                password="$realm"
                realm=ManagementRealm
            fi
            log "Creating user $user"
            /opt/wildfly/bin/add-user.sh -u "$user" -p "$password" -r "$realm"
        fi
    done
fi
password=

log "Starting WildFly"
/opt/wildfly/bin/standalone.sh $@
