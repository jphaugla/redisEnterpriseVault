This directory used for testing of Vault and ACL.  Each of the yaml files are deployed using `kubectl apply -f redis1.yaml`
Ran tests with 4 databases, 10 databases and then 10 databases with the *big* 100 shard database.   Ran the tests by logging
into vault with `kubectl -n vault exec --stdin=true --tty=true vault-0 -- /bin/bash`  and running a vault read for loop
at 1 second and .5 second waits between reads.  Tested using one role for all the databases versus a separate role for the redis1 database.

*NOTE*: the previous results are exported to a csv file in this directory
