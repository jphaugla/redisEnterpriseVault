# redisEnterpriseVault - Redis Enterprise integrated with Hashicorp Vault to migrate data from postgresql using redis connect

## Purpose

Redis Connect Demo integrating Redis Enterprise and Postgresql with Hashicorp Vault with all components running in kubernetes.
Optional path is included to deploy without Vault.

&nbsp;

## Outline

- [Overview](#overview)
- [Important Links](#important-links)
- [Technical Overview](#technical-overview)
- [Instructions](#instructions)
  - [Prepare repository working directories](#prepare-repository-working-directories)
  - [Create GKE cluster](#create-gke-cluster)
  - [Install Redis Enterprise k8s](#install-redis-enterprise-k8s)
  - [Create Redis Enterprise Databases](#create-redis-enterprise-databases)
  - [Add Redisinsights](#add-redisinsights)
  - [Install Kubegres](#install-kubegres)
  - [Vault](#vault)
  - [Redis Connect](#redis-connect-configuration)
    - [Redis Connect with Vault](#redis-connect-with-vault)
    - [Redis Connect without Vault](#redis-connect-without-vault)
- [Debug Ideas](#debug-ideas)
  
&nbsp;

## Overview
Set up full set of tools to do redis connect between postgresql and redis enterprise using GKE cluster and vault.  All software pieces 
will run in separate namespaces in a GKE cluster.
![Solution Diagram](images/redis_connect_k8s_postgres.png)

## Important Links

* [Set up vault on GKE](https://learn.hashicorp.com/tutorials/vault/kubernetes-google-cloud-gke)
* [Redis Connect Tips](https://github.com/Redislabs-Solution-Architects/redis-connect-k8s-helpers)
* [Kubegres is a kubernetes operator for postgresql](https://www.kubegres.io/)
* [Redis Enterprise k8s github](https://github.com/RedisLabs/redis-enterprise-k8s-docs)
* [Redis Enterprise k8s quickstart docs](https://docs.redis.com/latest/kubernetes/deployment/quick-start/)
* [Redis Enterprise k8s docs](https://docs.redis.com/latest/kubernetes/deployment/)
* [Hashicorp Vault plugin on Redis Enterprise k8s](https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/blob/main/docs/guides/using-the-plugin-on-k8s.md)
* [Redis Connect Postgres Sample](https://github.com/redis-field-engineering/redis-connect-dist/tree/main/examples/postgres)
* [Kubernetes Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [Install RedisInsights on k8s](https://docs.redis.com/latest/ri/installing/install-k8s/)
* [Vault k8 injector](https://www.vaultproject.io/docs/platform/k8s/injector)

## Technical Overview

* Follow the instructions using link above to "Set up vault on GKE"
* Install Redis Enterprise on k8s using "Redis Enterprise k8s" link
* Set up Postgresql using Kubegres
* If using Vault, Setup Vault and "Hashicorp Vault plugin on Redis Enterprise k8s"
* Work through Redis Connect using "With" or "Without" vault

&nbsp;

---

&nbsp;

## Instructions

### Run with terraform ansible
* apply additional pip installs
```bash
pip3 install requests
pip3 install google-auth
pip3 install kubernetes
pip3 install psycopg2
```
I had errors on the last install and need use [this psycopg2 install debug](https://stackoverflow.com/questions/27264574/import-psycopg2-library-not-loaded-libssl-1-0-0-dylib)   
The suggestion that worked for me was this
```bash
pip3 install --global-option=build_ext \
            --global-option="-I/usr/local/opt/openssl/include" \
            --global-option="-L/usr/local/opt/openssl/lib" psycopg2
```

### Run manually

***IMPORTANT NOTE**: Creating this demo application in your GCP account will create and consume GCP resources, which **will cost money**.

&nbsp;

There are a large number of directories to keep track of files.  A provided script will set up the following environment variables to make the task less arduous.  
Another tip would be to have a window opened to each of the directories instead of relying on one terminal session.  
Additionally, label each terminal session for the directory path in use.

### Prepare repository working directories
To get all of these moving parts working, multiple repositories are needed.  Then, a large number of directory changes are needed as different pieces are deployed.  
To facilitate this, first set up the environment with a provided scripts and then pull all the necessary repositories.  Decide on one home git directory that will hold all the subdirectories needed.  The default in the environment scirpt is ```$HOME/gits```
* Move to chosen git directory home and pull down the repositories
```bash
git clone https://github.com/jphaugla/redisEnterpriseVault.git
git clone https://github.com/RedisLabs/redis-enterprise-k8s-docs.git
git clone https://github.com/redis-field-engineering/redis-connect-dist.git
```
* edit and then source the environment files for subsequent steps
```bash
cd redisEnterpriseVault
source setEnvironment.sh

```
### Create GKE cluster 

Tips on installing GKE
* Easier to use GCP console to get the desired node size.
* Make sure compute nodes are decent size *e2-standard-8*.  
* Start with 3 nodes in the default node pool-can always increase as needed.
* Once the GKE cluster is created, connect to the cluster.  To do this:
    * Click on newly created cluster
![Select GKE Cluster](images/SelectGKEcluster.png)
    * Click to connect to the cluster
![Connect to Cluster](images/ConnectToCluster.png)
    * Follow the command-line access instructions to prepare for the subsequent steps

### Install Redis Enterprise k8s
* Get to redis enterprise k8s docs directory
```bash
cd $GIT_RE_K8S
```
* Follow [Redis Enterprise k8s installation instructions](https://docs.redis.com/latest/kubernetes/deployment/quick-start/) using *demo* as the namespace.  Stop before the step to *Enable the Admission Controller".  This step is not needed

### Create redis enterprise databases
* Create two redis enterprise databases.  The first database is the Target database for redis connect and the second stores meta-data for redis-connect
  * If, the redis-meta database doesn't create, it may be the version of the timeseries module as it must fit with the deployed version.  Verify the module version for this redis enterprise version using [the release notes](https://docs.redis.com/latest/rs/release-notes/)
```bash
cd $DEMO
kubectl apply -f redis-enterprise-database.yml
kubectl apply -f redis-meta.yml
```
* Try cluster username and password script as well as databases password and port information scripts
```bash
./getDatabasePw.sh
./getClusterUnPw.sh
```
#### Add Redisinsights 
These instructions are based on [Install RedisInsights on k8s](https://docs.redis.com/latest/ri/installing/install-k8s/)
&nbsp;
The above instructions have two options for installing redisinights, this uses the second option to install 
[without a service](https://docs.redis.com/latest/ri/installing/install-k8s/#create-the-redisinsight-deployment-without-a-service) (avoids creating a load balancer)
* The yaml file apply below, creates redisinsights
* Since no load balancer is deployed, must do a port-forward to be able to access redisinsights from the local machine's browser
* Easiest, to open a new terminal window and label the terminal window *redisinsights port forward*
```bash
kubectl apply -f redisinsight.yml
kubectl port-forward deployment/redisinsight 8001
```
* from chrome or firefox, open the browser using http://localhost:8001
* Click "I already have a database"
* Click "Connect to Redis Database"
* Create Connection to target redis database with following parameter entries

| Key      | Value                                     |
|----------|-------------------------------------------|
| host     | redis-enterprise-database.demo            |
| port     | 18154 (get from ./getDatabasepw.sh above) |
| name     | TargetDB                                  |
| Username | (leave blank)                             |
| Password | DrCh7J31 (from ./getDatabasepw.sh above) |
* click ok
*repeat steps above for metadata database using following parameters

| Key      | Value                                     |
|----------|-------------------------------------------|
| host     | redis-meta.demo                           |
| port     | 15871 (get from ./getDatabasepw.sh above) |
| name     | metaDB                                    |
| Username | (leave blank)                             |
| Password | FW2mFXEH (from ./getDatabasepw.sh above)  |

### Install Kubegres
Based on the instructions so also read these as steps are performed for deeper explanation [Kubegres getting started](https://www.kubegres.io/doc/getting-started.html)
This creates kubegres, creates a postgres.conf configmap to enable postgres replication, adds postgres database and password, and creates the one node database
The replication technique with the configmap uses this link  [Override default configs](https://www.kubegres.io/doc/override-default-configs.html)
```bash
cd $POSTGRES
kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.15/kubegres.yaml
kubectl create namespace postgres
kubectl config set-context --current --namespace=postgres
kubectl apply -f postgres-conf-override.yaml
kubectl apply -f my-postgres-secret.yaml
kubectl apply -f my-postgres.yaml
```
* create database and tables needed for redis-connect
  * find the pod name for postgres 
  * copy database and table creation to pod 
  * use the password in the my-postgres-secret.yaml file when prompted with psql
```bash
cd $SAMPLES
kubectl get pods
kubectl -n postgres cp postgres_cdc.sql mypostgres-1-0:/
kubectl -n postgres exec --stdin --tty  mypostgres-1-0 -- /bin/sh
psql -Upostgres -W
create database "RedisConnect";
\c "RedisConnect"
\i postgres_cdc.sql
```

### Vault

#### Install helm and vault on GKE
* Reference both of these links
  * [Set up vault on GKE](https://learn.hashicorp.com/tutorials/vault/kubernetes-google-cloud-gke)
  * [Hashicorp Vault plugin on Redis Enterprise k8s](https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/blob/main/docs/guides/using-the-plugin-on-k8s.md)
```bash
cd $VAULT
kubectl create namespace vault
kubectl config set-context --current --namespace=vault
brew install helm
brew install jq
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault --namespace vault -f override-values.yaml
```  
#### unseal the vault
* This follows the technique from within this link [Set up vault on GKE](https://learn.hashicorp.com/tutorials/vault/kubernetes-google-cloud-gke).  Read this section for explanation of these commands.
* The operator init writes pertinent keys to the cluster-keys.json file for safe keeping, obtain unseal key, unseal the vault and display status
```bash
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
export VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-0 -- vault status
```
* To use the vault, a token is needed.  For this exercise, use the root token to login

```bash
cat cluster-keys.json | jq -r ".root_token"
export CLUSTER_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")
kubectl exec vault-0 -- vault login $CLUSTER_ROOT_TOKEN
```
#### Download the plugin file
Make sure you grab the correct file-many similarly named files
* download vault-plugin-database-redis-enterprise_0.1.3_linux_amd64
https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/releases
* need to change the permissions, copy the file to the vault container, and pull the shasum for used later
```bash
mv ~/Downloads/vault-plugin-database-redis-enterprise_0.1.3_linux_amd64 $VAULT
kubectl cp -n vault $VAULT/vault-plugin-database-redis-enterprise_0.1.3_linux_amd64 vault-0:/usr/local/libexec/vault
shasum -a 256 $VAULT/vault-plugin-database-redis-enterprise_0.1.3_linux_amd64| awk '{print $1}'
```
* get the cluster and database password information for use while logged into vault
```bash
$DEMO/getDatabasePw.sh
$DEMO/getClusterUnPw.sh
```
####  log to vault container and enable vault plugin
Use the shasum value pulled from above and not the current value set equal to sha256
```bash
kubectl -n vault exec --stdin=true --tty=true vault-0 -- /bin/sh
vault write sys/plugins/catalog/database/redisenterprise-database-plugin command=vault-plugin-database-redis-enterprise_0.1.3_linux_amd64 sha256=739421599adfe3cdc53c8d6431a3066bfc0062121ba8c9c68e49119ab62a5759
```
#### Create database configurations in vault
Using the information from the getClusterUnPw.sh script from above and using the username and password valued for redis enterprise cluster authentication.   
For additional explanations peruse [Hashicorp Vault plugin on Redis Enterprise k8s](https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/blob/main/docs/guides/using-the-plugin-on-k8s.md)
```bash
chmod 755 /usr/local/libexec/vault/vault-plugin-database-redis-enterprise_0.1.3_linux_amd64
vault secrets enable database
vault write database/config/demo-test-rec-redis-enterprise-database plugin_name="redisenterprise-database-plugin" url="https://test-rec.demo.svc:9443" allowed_roles="*" database=redis-enterprise-database username=demo@redislabs.com password=vubYurxK
vault write database/config/demo-test-rec-redis-meta plugin_name="redisenterprise-database-plugin" url="https://test-rec.demo.svc:9443" allowed_roles="*" database=redis-meta username=demo@redislabs.com password=vubYurxK
```
#### Create database roles
```bash
vault write database/roles/redis-enterprise-database db_name=demo-test-rec-redis-enterprise-database creation_statements="{\"role\":\"Admin\"}" default_ttl=90m max_ttl=100m
vault write database/roles/redis-meta db_name=demo-test-rec-redis-meta creation_statements="{\"role\":\"Admin\"}" default_ttl=90m max_ttl=100m
```
#### test the database connections
Using the information from getDatabasePw.sh above.  Read the authentication parameters and use the returned values for subsequent authentication step, substituting returned values for the password and port
Grab another new terminal window to runt the port forward command.  (note, need the actual port from getDatabasePw.sh)

```bash
kubectl port-forward -n demo service/redis-enterprise-database 18154:18154
kubectl port-forward -n demo service/redis-meta 16254:16254
```
NOTES:  
* the redis-cli command is using the username and password from the output of the read database command
* the vault read command must be done from the vault terminal 
  * can log in to the vault container using  ```kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh```
* From vault for redis-enterprise-database
```bash

vault read database/creds/redis-enterprise-database
      Key                Value
      ---                -----
      lease_id           database/creds/redis-enterprise-database/JVsEvOrtZfK46dMO7GWRxjTW
      lease_duration     90m
      lease_renewable    true
      password           blZxlE10AS-zy-UBbjdh
      username           v_root_redis-enterprise-database_sruv9v0fewy2rv4m1oxq_1646252982
```
* From vault for redis-meta 
```bash
vault read database/creds/redis-meta
      Key                Value
      ---                -----
      lease_id           database/creds/redis-meta/iahGKJ9XNkisGsyLgW89Ohpt
      lease_duration     90m
      lease_renewable    true
      password           Vfo2ajqBvWAVKFyI-ojR
      username           v_root_redis-meta_n2dkafecjttws9mzj9eg_1646411445
```
Open a new terminal window  and test each database using the username and password values from the vault read database output
* redis-enterprise-database
```bash
redis-cli -p 18154
>AUTH v_root_redis-enterprise-database_sruv9v0fewy2rv4m1oxq_1646252982 blZxlE10AS-zy-UBbjdh
```
* redis-meta
```bash
redis-cli -p 16254
>AUTH v_root_redis-meta_n2dkafecjttws9mzj9eg_1646411445 Vfo2ajqBvWAVKFyI-ojR
```

#### Authorize kubernetes
* using vault terminal connection...   
```bash
vault auth enable kubernetes
vault secrets enable kubernetes
vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```
* don't log out of vault, keep vault connection in a separate terminal and use the vault terminal as directed

### Redis Connect Configuration
* create service account and namespace
```bash
cd $REDIS_CONNECT
kubectl create sa redis-connect
kubectl create namespace redis-connect
kubectl config set-context --current --namespace=redis-connect
```
#### Redis Connect With Vault
not needed if not doing vault (skip to [Redis Connect Without Vault](#redis-connect-without-vault))
* go to vault terminal
```bash
vault write database/config/kube-postgres \
    plugin_name=postgresql-database-plugin \
    allowed_roles="redis-connect" \
    username="postgres" \
    password="jasonrocks" \
    connection_url="postgresql://{{username}}:{{password}}@mypostgres.postgres.svc:5432/RedisConnect?sslmode=disable"
vault write database/roles/redis-connect \
    db_name=kube-postgres \
    creation_statements="CREATE ROLE \"{{name}}\" WITH REPLICATION LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
         GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; \
         ALTER USER \"{{name}}\" WITH SUPERUSER;" \
    default_ttl="60m" \
    max_ttl="60m"
```
* create redis-connect policy and role
```bash
vault policy write redis-connect-policy - <<EOF
 path "database/creds/redis-enterprise-database" {
   capabilities = ["read"]
 }
 path "database/creds/redis-meta" {
   capabilities = ["read"]
 }
path "database/creds/redis-connect" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/redis-connect \
    bound_service_account_names=redis-connect \
    bound_service_account_namespaces=redis-connect \
    policies=redis-connect-policy \
    ttl=24h
```
* Edit the jobmanager.properties file for the correct connection parameters in redis.connection.url
  * these parameters can be retrieved using ```$DEMO/getDatabasePw.sh```
* create configmap with jobmanager.properties
  * this configmap is used in the redis-connect-start.yaml to mount files appropriately
* start the redis-connect server
```bash
$DEMO/getDatabasePw.sh
vi jobmanager.properties
kubectl create configmap redis-connect-config \
  --from-file=jobmanager.properties=jobmanager.properties 
kubectl apply -f vault/redis-connect-start.yaml
```
#### Redis Connect Without Vault
* Edit the jobmanager.properties file for the correct connection parameters in redis.connection.url
  * these parameters can be retrieved using ```$DEMO/getDatabasePw.sh```
* Edit each credentials file for the appropriate connection information
  * For redisconnect_credentials_jobmanager.properties (redis-meta) and redisconnect_credentials_redis_postgres-job.properties (redis-enterprise-db) can use a null username and the password from getDatabasePw.sh
* create configmap with jobmanager.properties and the credentials files
  * this configmap is used in the redis-connect-start.yaml to mount files appropriately
* start the redis-connect server
```bash
$DEMO/getDatabasePw.sh
vi jobmanager.properties
kubectl create configmap redis-connect-config \
  --from-file=jobmanager.properties=jobmanager.properties \
  --from-file=redisconnect_credentials_jobmanager.properties=non-vault/redisconnect_credentials_jobmanager.properties \
  --from-file=redisconnect_credentials_redis_postgres-job.properties=non-vault/redisconnect_credentials_redis_postgres-job.properties \
  --from-file=redisconnect_credentials_postgresql_postgres-job.properties=non-vault/redisconnect_credentials_postgresql_postgres-job.properties 
kubectl apply -f non-vault/redis-connect-start.yaml
```


### Test replication
This section will define the redis-connect job using an API approach.  For more detail on the redis-connect swagger interface, see this
[demo section](https://github.com/redis-field-engineering/redis-connect-dist/examples/postgres/demo) in redis connection github
In another terminal, need to port-forward the rest API interface to set up the actual job
```bash
kubectl port-forward pod/redis-connect-59475bcdd4-nwv5v 8282:8282
```
Use the [swagger interface]( http://localhost:8282/swagger-ui/index.html) to define the job and control the job execution
* Save the job configuration using swagger interface ![swagger](images/swagger1.png)
  * click on *POST* Save Job Configuration to bring up the API interface ![API](images/swagger-save-job.png)
  * click on *Try It Out*
  * Enter the jobname of *postgres-job*
  * Click on *browse* and select the redis-connect/postgres-job.json
  * Click on *Execute*
* Insert rows using postgres container
```bash
kubectl -n postgres exec --stdin --tty  mypostgres-1-0 -- /bin/sh
psql -Upostgres -W
\c "RedisConnect"
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (1, 'Allen', 'Terleto', 'FieldCTO', 1, '2018-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (2, 'Brad', 'Barnes', 'SA Manager', 1, '2019-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (3, 'Virag', 'Tripathi', 'Troublemaker', 1, '2020-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (4, 'Jason', 'Haugland', 'SA', 1, '2021-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (5, 'Ryan', 'Bee', 'Field Sales', 1, '2005-08-06', 20000, 10, 1);
```
* Run the initial bulk load of the job ![swagger start](images/swaggerStartjob.png)
  * Click on *POST* START Job to biring up the API interface ![API start](images/swagger-run-load.png)
  * click on *Try It Out*
  * Enter the jobname of *postgres-job*
  * Enter the jobtype of *load*
* Test the results
  * Use the [redisinsights](#add-redisinsights) to verify the data is loaded to redis
* Run the stream load ![swagger start](images/swaggerStartjob.png)
  * Click on *POST* START Job to bring up the API interface ![API start](images/swagger-run-load.png)
```bash
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (111, 'Simon', 'Prickett', 'Tech Advocate', 1, '2016-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (112, 'Doug', 'Snyder','Territory Manager', 1, '2021-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (113, 'Jason', 'Plotch', 'Territory Manager', 1, '2021-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (114, 'Nail', 'Sirazitdinov', 'TAM', 1, '2010-08-06', 20000, 10, 1);
INSERT INTO public.emp (empno, fname, lname, job, mgr, hiredate, sal, comm, dept) VALUES (115, 'Manish', 'Arora', 'SA', 1, '2021-08-06', 20000, 10, 1);
```
* Test the results
  * Use the [redisinsights](#add-redisinsights) to verify the data is loaded to redis
  
### Debug Ideas
* Redis-connect job [documentation link](https://github.com/redis-field-engineering/redis-connect-dist/tree/main/examples/postgres/demo#start-redis-connect)
* look for resulting rows in redis enterprise using redisinsight (see directions above)
* There are multiple methods to debug the running job.  Here are a few:
  * Find the pod name(s) for redis connect
  * get the logs for init and main container

```bash
kubectl -n redis-connect get pods
kubectl -n redis-connect logs redis-connect-postgres-595d6fb5f4-54c6v -c vault-agent-init
kubectl -n redis-connect logs redis-connect-postgres-595d6fb5f4-54c6v -c vault-agent
kubectl -n redis-connect logs redis-connect-postgres-595d6fb5f4-54c6v -c redis-connect
kubectl -n redis-connect exec --stdin --tty  redis-connect-687bd546fc-44kvc -- /bin/sh
```
  * log in to the pod and look at log files 
  * there is a debug line in redis-connect-start.yaml that keeps the pod running even if there are connection errors-this is great for debug
  * NOTE: check the swagger UI for API commands that are easier to use than redisconnect.sh
  * Check the file systems mounted correctly
```bash
cd logs
# investigate the log files 
vi *
# login to cli
cd ../bin
./redisconnect.sh cli
> validate connection -t JDBCConnectionProvider -i RDBConnection
exit
df -h
```
this should be output from the df -h
![df ouput](images/redis-connect-mounts.png)
  * Ensure each credential file is named correctly
  * Test the username/password from the credential file to ensure the connection works from the respective database
