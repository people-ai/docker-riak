#!/bin/bash

if [ -z $SCHEMAS_DIR ]; then
    SCHEMAS_DIR=/etc/riak/schemas
fi

# Create KV bucket types
echo "Looking for datatypes in $SCHEMAS_DIR..."
for f in $(find $SCHEMAS_DIR -name *.dt -print); do
  BUCKET_NAME=$(basename -s .dt $f)
  BUCKET_DT=$(cat $f)
  if [ "$BUCKET_DT" == "json" ]; then
    $RIAK_ADMIN bucket-type create $BUCKET_NAME "{\"props\":{\"n_val\":1,\"allow_mult\":false}}"
  else
    $RIAK_ADMIN bucket-type create $BUCKET_NAME "{\"props\":{\"datatype\":\"$BUCKET_DT\"}}"
  fi
  $RIAK_ADMIN bucket-type activate $BUCKET_NAME
done
