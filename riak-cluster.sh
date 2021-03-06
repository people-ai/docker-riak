#!/bin/bash
#
# Cluster start script to bootstrap a Riak cluster.
#
set -ex

if [[ -x /usr/sbin/riak ]]; then
  export RIAK=/usr/sbin/riak
else
  export RIAK=$RIAK_HOME/bin/riak
fi
export RIAK_CONF=/etc/riak/riak.conf
export USER_CONF=/etc/riak/user.conf
export RIAK_ADVANCED_CONF=/etc/riak/advanced.config
if [[ -x /usr/sbin/riak-admin ]]; then
  export RIAK_ADMIN=/usr/sbin/riak-admin
else
  export RIAK_ADMIN=$RIAK_HOME/bin/riak-admin
fi
export SCHEMAS_DIR=/etc/riak/schemas/

# Set ports for PB and HTTP
export PB_PORT=${PB_PORT:-8087}
export HTTP_PORT=${HTTP_PORT:-8098}

export HOST=$(hostname --fqdn)||'127.0.0.1'
export IP=$(ping -c1 $HOSTNAME | awk '/^PING/ {print $3}' | sed 's/[()]//g')||'127.0.0.1'


# ulimit
echo "* hard nofile 94000" >> /etc/security/limits.conf
echo "* soft nofile 94000" >> /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session

# CLUSTER_NAME is used to name the nodes and is the value used in the distributed cookie
export CLUSTER_NAME=${CLUSTER_NAME:-riak}

# The COORDINATOR_NODE is the first node in a cluster to which other nodes will eventually join
export COORDINATOR_NODE=${COORDINATOR_NODE:-$HOSTNAME}
export COORDINATOR_NODE_HOST="$COORDINATOR_NODE"

# Run all prestart scripts
PRESTART=$(find /etc/riak/prestart.d -name *.sh -print | sort)
for s in $PRESTART; do
  . $s
done

chown riak:riak /var/lib/riak

# Start the node and wait until fully up
$RIAK start
$RIAK_ADMIN wait-for-service riak_kv

# Run all poststart scripts
POSTSTART=$(find /etc/riak/poststart.d -name *.sh -print | sort)
for s in $POSTSTART; do
  . $s || true
done

# Tail the log file indefinitely
tail -n 1024 -f /var/log/riak/console.log
