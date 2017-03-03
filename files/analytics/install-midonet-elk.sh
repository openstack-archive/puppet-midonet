#!/bin/bash -eux
#
# WORKAROUND:
# In some cases the package midonet-elk doesn't get installed properly
# and some of the packaged files are not placed where they should
# (e.g. /etc/logstash/conf.d/midonet.conf)

# Check if MidoNet logstash configuration file is there
if [ -f /etc/logstash/conf.d/midonet.conf ]; then
  exit 0
fi

# Purge midonet-elk and reinstall it, the hard way
rpm -e --justdb --nodeps midonet-elk
yumdownloader --destdir /tmp/ midonet-elk
yum localinstall /tmp/midonet-elk*.rpm
cd /
rpm2cpio /tmp/midonet-elk*.rpm | cpio -idmv
rm /tmp/midonet-elk*.rpm

# Restart logstash if already running
systemctl status logstash.service | grep running > /dev/null && systemctl restart logstash.service || true

exit 0
