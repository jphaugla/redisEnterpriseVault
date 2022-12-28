kubectl -n demo get secret/test-rec -o=jsonpath={.data.password} | base64 -d
