kubectl -n demo get secret/test-rec -o=jsonpath={.data.username} | base64 -d
