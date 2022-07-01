#  this is based on this jq technique https://michaelheap.com/sum-values-with-jq/
curl -X GET -H "Content-Type: application/json" -v -k -u demo@redislabs.com:h4rnQ0PF 'https://localhost:9443/v1/nodes' |jq  '[.[].shard_count | tonumber] | add'
