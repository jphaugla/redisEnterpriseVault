kubectl exec -it pod/redis-di-cli -- redis-di scaffold --db-type postgresql --preview debezium/application.properties > application.properties

