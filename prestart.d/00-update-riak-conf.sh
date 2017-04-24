#!/bin/bash

# Add standard config items

cat <<END >>$RIAK_CONF
nodename = riak@$HOST
distributed_cookie = $CLUSTER_NAME
listener.protobuf.internal = $IP:$PB_PORT
listener.http.internal = $IP:$HTTP_PORT
storage_backend = leveldb
END

cat <<END >$RIAK_ADVANCED_CONF
[
    {riak_kv, [
        {add_paths, ['/etc/riak/plugins']}
    ]}
].
END

# Maybe add user config items
if [ -s $USER_CONF ]; then
  cat $USER_CONF >>$RIAK_CONF
fi
