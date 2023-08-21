export REC=test-rec-1
export NS=demo
export WILDCARD_DOMAIN=openshift.demo.redislabs.com
# export WILDCARD_DOMAIN=jph-gke.demo.redislabs.com
export RE_USERNAME=demo@redis.com
#  DON'T FORGET TO CHANGE PASSWORD!!!
export RE_PASSWORD=Ui3QsKPO
nslookup api-${REC}-${NS}.${WILDCARD_DOMAIN}
# curl -X GET -u $RE_USERNAME:$RE_PASSWORD -k https://api-${REC}-${NS}.${WILDCARD_DOMAIN}/v1/cluster/certificates | jq -r .proxy_cert > proxy_cert-${REC}.pem
curl -X GET -u $RE_USERNAME:$RE_PASSWORD -k https://api-${REC}-${NS}.${WILDCARD_DOMAIN}/v1/cluster
# curl -X GET -k -u $RE_USERNAME:$RE_PASSWORD https://api-${REC}-${NS}.${WILDCARD_DOMAIN}/v1/cluster/certificates 
# curl -X GET -k -u $RE_USERNAME:$RE_PASSWORD https://api-${REC}-${NS}.${WILDCARD_DOMAIN}:9443/v1/bdbs
# curl -X GET -k -u $RE_USERNAME:$RE_PASSWORD https://api-${REC}-${NS}.${WILDCARD_DOMAIN}:80/v1/bdbs
# curl -X GET -k -u $RE_USERNAME:$RE_PASSWORD http://api-${REC}-${NS}.${WILDCARD_DOMAIN}/v1/bdbs
# curl -X GET -k -u $RE_USERNAME:$RE_PASSWORD https://localhost:9443/v1/bdbs
