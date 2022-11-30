#!/bin/sh
set -e

#
# Do initial setup for the environment
#
TARGET="$1"

if [ ! -d "${TARGET}" ]
then
    echo "E: Target directory '${TARGET}' not found!"
    exit 1
fi

mkdir -p "${TARGET}/etc/apt/apt.conf.d" "${TARGET}/etc/dpkg/dpkg.cfg.d"

cat > "${TARGET}/etc/apt/apt.conf.d/99seravo" << EOF
# Don't acquire translation files
Acquire::Languages "none";
EOF

cat > "${TARGET}/etc/dpkg/dpkg.cfg.d/99seravo" << EOF
#
# Create minimal image by excluding lots of documentation etc.
#

#path-exclude=/usr/share/man/man1/*
#path-exclude=/usr/share/man/man2/*
#path-exclude=/usr/share/man/man3/*
#path-exclude=/usr/share/man/man4/*
#path-exclude=/usr/share/man/man5/*
#path-exclude=/usr/share/man/man6/*
#path-exclude=/usr/share/man/man7/*
#path-exclude=/usr/share/man/man8/*
#path-exclude=/usr/share/man/man9/*
path-exclude=/usr/share/doc/*
path-exclude=/usr/share/locale/*
path-exclude=/usr/share/gnome/help/*/*
path-exclude=/usr/share/omf/*/*-*.emf
path-include=/usr/share/locale/locale.alias
path-include=/usr/share/locale/en/*
path-include=/usr/share/locale/en_US.UTF-8/*
path-include=/usr/share/omf/*/*-en.emf
path-include=/usr/share/omf/*/*-en_US.UTF-8.emf
path-include=/usr/share/omf/*/*-C.emf
path-include=/usr/share/locale/languages
path-include=/usr/share/locale/all_languages
path-include=/usr/share/locale/currency/*
path-include=/usr/share/locale/l10n/*
EOF

mkdir -p "${TARGET}/usr/sbin"

cat > "${TARGET}/usr/sbin/apt-setup" << EOF
#!/bin/sh
set -e

#
# Configure APT and fetch package lists
#

if [ -n "\${APT_PROXY}" ]
then
    echo "I: Set APT proxy '\${APT_PROXY}'."
    echo "Acquire::HTTP::Proxy \"\${APT_PROXY}\";" > /etc/apt/apt.conf.d/99proxy
    echo "Acquire::HTTPS::Proxy \"none\";" >> /etc/apt/apt.conf.d/99proxy
fi

apt-get update
EOF

cat > "${TARGET}/usr/sbin/apt-cleanup" << EOF
#!/bin/sh
set -e

#
# Remove APT-related cruft from the system
#

export DEBIAN_FRONTEND="noninteractive"

# Remove packages that were automatically installed, but are not longer needed
# by other packages.
echo "Autoremove installed packages no longer needed..."
apt-get --assume-yes autoremove

# Purge deinstalled packages
echo "Purge deinstalled packages..."
dpkg --get-selections |grep deinstall |awk '{print \$1}' |xargs --no-run-if-empty apt-get --assume-yes --purge remove

echo "Clean up APT caches..."
apt-get clean

echo "Remove APT proxy config..."
rm -f /etc/apt/apt.conf.d/99proxy
#echo "Remove docs..."
#rm -rf /usr/share/doc/*
#echo "Remove locales..."
#rm -rf /usr/share/locale/*
#echo "Remove man pages..."
#rm -rf /usr/share/man/*
echo "Remove downloaded lists and archives..."
rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin /var/cache/apt/archives/*.deb
mkdir -p /var/lib/apt/lists/partial
EOF

cat > "${TARGET}/usr/sbin/apt-upgrade" << EOF
#!/bin/sh
set -e

#
# Upgrade environment
#

MODE="\$1"
if [ -z "\${MODE}" ]
then
    MODE="upgrade"
fi

export DEBIAN_FRONTEND="noninteractive"

case "\${MODE}" in
    upgrade)
        apt-get --assume-yes upgrade
        ;;
    dist-upgrade)
        apt-get --assume-yes dist-upgrade
        ;;
    *)
        echo "Invalid mode: \${MODE}"
        exit 1
esac
EOF

chmod +x "${TARGET}/usr/sbin/apt-setup" "${TARGET}/usr/sbin/apt-cleanup" "${TARGET}/usr/sbin/apt-upgrade"
