#!/bin/sh

# Directories
DESTDIR="$1"
CONFIG_DIR="${DESTDIR}/etc/pihole"
SCRIPTS_DIR="${DESTDIR}/opt/pihole"
BIN_DIR="${DESTDIR}/usr/bin"
BASH_COMPLETION_DIR="${DESTDIR}/etc/bash_completion.d"
DNSMASQ_CONFIG_DIR="${DESTDIR}/etc/dnsmasq.d"
SUDOERS_DIR="${DESTDIR}/etc/sudoers.d"
CRON_DIR="${DESTDIR}/etc/cron.d"
LOGROTATE_DIR="${DESTDIR}/etc/logrotate.d"
SHARE_DIR="${DESTDIR}/usr/share/pihole"

# Files
SETUP_VARS_FILE="${CONFIG_DIR}/setupVars.conf"
ADLIST_FILE="${CONFIG_DIR}/adlists.list"
DNSMASQ_CONFIG_FILE="${DESTDIR}/etc/dnsmasq.conf"
SUDOERS_FILE="${SUDOERS_DIR}/pihole"
CRON_FILE="${CRON_DIR}/pihole"
LOGROTATE_FILE="${LOGROTATE_DIR}/pihole"
GRAVITY_SCHEMA_FILE="${SHARE_DIR}/gravity.sql"

# Create required directories
create_directories() {
    install -d -m 755 "${CONFIG_DIR}"
    install -d -m 755 "${SCRIPTS_DIR}"
    install -d -m 755 "${BIN_DIR}"
    install -d -m 755 "${BASH_COMPLETION_DIR}"
    install -d -m 755 "${DNSMASQ_CONFIG_DIR}"
    install -d -m 755 "${SUDOERS_DIR}"
    install -d -m 755 "${CRON_DIR}"
    install -d -m 755 "${LOGROTATE_DIR}"
}

# Install the Core scripts
install_scripts() {
    install -m 755 -t "${SCRIPTS_DIR}" gravity.sh
    install -m 755 -t "${SCRIPTS_DIR}" advanced/Scripts/*.sh
    install -m 755 -t "${SCRIPTS_DIR}" advanced/Scripts/COL_TABLE
    install -m 755 -t "${BIN_DIR}" pihole
    install -m 644 -t "${BASH_COMPLETION_DIR}" advanced/bash-completion/pihole
    install -m 755 -t "${SHARE_DIR}" package-scripts/configure.sh
}

# Install data files
install_data() {
    install -m 644 advanced/Templates/gravity.db.sql "${GRAVITY_SCHEMA_FILE}"
}

# Install configs
install_configs() {
    # Install Dnsmasq config
    echo "conf-dir=/etc/dnsmasq.d" > "${DNSMASQ_CONFIG_FILE}"
    chmod 644 "${DNSMASQ_CONFIG_FILE}"

    # Install cron config
    install -m 644 advanced/Templates/pihole.cron "${CRON_FILE}"

    # Install sudoers config
    install -m 0440 advanced/Templates/pihole.sudo "${SUDOERS_FILE}"

    # Install logrotate config
    install -m 644 advanced/Templates/logrotate "${LOGROTATE_FILE}"
}

# Set default adlists
create_adlists() {
    {
        echo "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        echo "https://mirror1.malwaredomains.com/files/justdomains"
        echo "http://sysctl.org/cameleon/hosts"
        echo "https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"
        echo "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
        echo "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
        echo "https://hosts-file.net/ad_servers.txt"
    }> "${ADLIST_FILE}"
    chmod 644 "${ADLIST_FILE}"
}

# Populate setupVars with default settings
create_setup_vars() {
    {
        echo "PIHOLE_DNS_1=1.1.1.1"
        echo "PIHOLE_DNS_2=1.0.0.1"
        echo "QUERY_LOGGING=true"
    }> "${SETUP_VARS_FILE}"
    chmod 644 "${SETUP_VARS_FILE}"
}

create_directories
install_scripts
install_data
install_configs
create_setup_vars
create_adlists
