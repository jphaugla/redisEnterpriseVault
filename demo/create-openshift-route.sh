kubectl patch rec test-rec-1 --type merge --patch "{\"spec\": \
    {\"ingressOrRouteSpec\": \
      {\"apiFqdnUrl\": \"api-test-rec-1-demo.openshift.demo.redislabs.com\", \
      \"dbFqdnSuffix\": \"-db-test-rec-1-demo.openshift.demo.redislabs.com\", \
      \"method\": \"openShiftRoute\"}}}"

