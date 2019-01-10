#!/bin/bash
ENDSTATE=$3
NAME=$2
TYPE=$1

notify_master() {
  systemctl start haproxy
}

echo "$TYPE" "$NAME" is in "$ENDSTATE" state > /var/run/keepalive."$TYPE"."$NAME".state
case "$ENDSTATE" in
  "BACKUP") # Perform action for transition to BACKUP state
            systemctl stop haproxy
            exit 0
            ;;
  "FAULT")  # Perform action for transition to FAULT state
            systemctl stop haproxy
            exit 0
            ;;
  "MASTER") # Perform action for transition to MASTER state
            notify_master && exit 0
            ;;
  *)        echo "Unknown state ${ENDSTATE} for VRRP ${TYPE} ${NAME}"
            exit 1
            ;;
esac
