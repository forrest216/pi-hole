#!/bin/sh

# This script will be called with the most recently configured version of
# Pi-hole before this one. If this is a fresh install, this will be empty.
PREVIOUS_VERSION="$1"

# Called only for fresh installs
fresh_install() {
    # Create the pihole user and group
    adduser --system --group --quiet pihole

    # Randomize gravity update time
    sed -i "s/59 1 /$((1 + RANDOM % 58)) $((3 + RANDOM % 2))/" /etc/cron.d/pihole
    # Randomize update checker time
    sed -i "s/59 17/$((1 + RANDOM % 58)) $((12 + RANDOM % 8))/" /etc/cron.d/pihole

    # Set the default interface
    INTERFACE=$(ip --oneline link show up | grep -v "lo" | awk '{print $2}' | \
        cut -d':' -f1 | cut -d'@' -f1 | head -n 1)
    echo "PIHOLE_INTERFACE=${INTERFACE}" >> /etc/pihole/setupVars.conf
}

# Called every time Pi-hole is configured
configure() {
    # Give the user ownership over various Pi-hole directories
    chown -R pihole:pihole /etc/pihole /opt/pihole /usr/share/pihole \
        /etc/dnsmasq.conf /etc/dnsmasq.d
}

# If there is no previous version, then run the fresh install commands
if [ -z "${PREVIOUS_VERSION}" ]; then
    fresh_install
fi

configure
