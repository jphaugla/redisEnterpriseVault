# remove finalizers from databases
kubectl -n demo patch redb redis-enterprise-database --type=json -p '[{"op":"remove","path":"/metadata/finalizers","value":"finalizer.redisenterprisedatabases.app.redislabs.com"}]'
kubectl -n demo patch redb redis-meta --type=json -p '[{"op":"remove","path":"/metadata/finalizers","value":"finalizer.redisenterprisedatabases.app.redislabs.com"}]'
kubectl -n demo patch rec test-rec-1 --type=json -p '[{"op":"remove","path":"/metadata/finalizers","value":"redbfinalizer.redisenterpriseclusters.app.redislabs.com"}]'
kubectl -n demo delete redb redis-enterprise-database
kubectl -n demo delete redb redis-meta
kubectl -n demo delete rec test-rec-1
kubectl delete namespaces demo
kubectl delete namespaces postgres
kubectl delete namespaces rdi
kubectl delete namespaces redis-connect
