kubectl -n rdi exec -it pod/redis-di-cli -- redis-di scaffold --db-type postgresql --preview config.yaml > config.yaml
