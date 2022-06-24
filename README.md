# redisEnterpriseVault - Redis Enterprise integrated with Hashicorp Vault to migrate data from postgresql using redis connect

## Purpose

Redis Connect Demo integrating Redis Enterprise and Postgresql with Hashicorp Vault

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
  - [Vault](#vault)
  - [Install Kubegres](#install-kubegres)
  - [Redis Connect](#redis-connect)
  
&nbsp;

## Overview
Set up full set of tools to do redis connect between postgresql and redis enterprise using GKE cluster and vault.  All software pieces 
will run in separate namespaces in a GKE cluster.
![Solution Diagram](redis-connect-k8s.png)

## Important Links

* [Set up vault on GKE](https://learn.hashicorp.com/tutorials/vault/kubernetes-google-cloud-gke)
* [Redis Connect Tips](https://github.com/Redislabs-Solution-Architects/redis-connect-k8s-helpers)
* [Kubegres is a kubernetes operator for postgresql](https://www.kubegres.io/)
* [Redis Enterprise k8s](https://github.com/RedisLabs/redis-enterprise-k8s-docs)
* [Hashicorp Vault plugin on Redis Enterprise k8s](https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/blob/main/docs/guides/using-the-plugin-on-k8s.md)
* [Redis Connect](https://github.com/redis-field-engineering/redis-connect-dist/tree/main/connectors/postgres/demo)
* [Kubernetes Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [Install RedisInsights on k8s](https://docs.redis.com/latest/ri/installing/install-k8s/)

## Technical Overview

* Follow the instructions using link above to "Set up vault on GKE"
* Install Redis Enterpise on k8s using "Redis Enterprise k8s" link
* Setup Vault and "Hashicorp Vault plugin on Redis Enterprise k8s"
* Set up Postgresql using Kubegres
* Work through "Redis Connect"

&nbsp;

---

&nbsp;

## Instructions

***IMPORTANT NOTE**: Creating this demo application in your GCP account will create and consume GCP resources, which **will cost money**.

&nbsp;

There are a large number of directories to keep track of files.  A provided script will set up the following environment variables to make the task less arduous.  Another tip would be to have a window opened to each of the directories instead of relying on one terminal session.  Additionally, label each terminal session for the directory path in use.

### Prepare repository working directories
To get all of these moving parts working, multiple repositories are needed.  Then, a large number of directory changes are needed as different pieces are deployed.  To facilitate this, first set up the environment with a provided scripts and then pull all the necessary repositories.  Decide on one home git directory that will hold all the subdirectories needed.  The default in the environment scirpt is ```$HOME/gits```
* Move to chosen git directory home and pull down the repositories
```bash
git clone https://github.com/jphaugla/redisEnterpriseVault.git
git clone https://github.com/RedisLabs/redis-enterprise-k8s-docs.git
git clone https://github.com/redis-field-engineering/redis-connect-dist.git
```
* edit the environment files for subsequent steps
```bash
cd redisEnterpriseVault
source setEnvironmant.sh

```
### Create GKE cluster 

* Tips on installing GKE
  * Instead of using the provided script to create the GKE cluster, make sure compute nodes are decent size *e2-standard-8*.  
  * Easier to use GCP console to get the desired node size.
  * Start with 3 nodes in the default node pool-can always increase as needed.
  * Once the GKE cluster is created, connect to the cluster.  To do this:
    * Click on newly created cluster
![Select GKE Cluster](/Users/jasonhaugland/gits/redisEnterpriseVault/images/SelectGKEcluster.png)
    * Click to connect to the cluster
![Connect to Cluster](/Users/jasonhaugland/gits/redisEnterpriseVault/images/ConnectToCluster.png)
    * Follow the command-line access instructions to prepare for the subsequent steps

### Install Redis Enterprise k8s
* Get to redis enterprise k8s docs directory
```bash
cd $GIT_RE_K8S
```
* Follow [Redis Enterprise k8s installation instructions](https://github.com/RedisLabs/redis-enterprise-k8s-docs#installation) all the way 
* through to step 4.  Use the demo namespace as instructed.  So after Step 4, done with this section
* Skip Step 5, the admission controller steps are not needed and neither are the webhook instructions
* Don't do Step 6 as the databases for this github are in the k8s subdirectory of this github

### Create redis enterprise databases
* Create two redis enterprise databases.  The first database is the Target database for redis connect and the second stores meta-data for redis-connect
  * If, the database doesn't create, it may be the version of the timeseries module as it must fit with the deployed version
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
#### Add redisinsights 
These instructions are based on [Install RedisInsights on k8s](https://docs.redis.com/latest/ri/installing/install-k8s/)
&nbsp;
The above instructions have two options for installing redisinights, this uses the second option to install
[ without a service](https://docs.redis.com/latest/ri/installing/install-k8s/#create-the-redisinsight-deployment-without-a-service) (avoids creating a load balancer)
* The yaml file apply below, creates redisinsights
```bash
kubectl apply -f redisinsight.yml
kubectl port-forward deployment/redisinsight 8001
```
* from chrome or firefox open the browser using http://localhost:8001
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
*
| Key      | Value                                     |
|----------|-------------------------------------------|
| host     | redis-meta.demo                           |
| port     | 15871 (get from ./getDatabasepw.sh above) |
| name     | metaDB                                    |
| Username | (leave blank)                             |
| Password | FW2mFXEH (from ./getDatabasepw.sh above)  |

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
Make sure you grab the correct file-many similarily named files
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
kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
vault write sys/plugins/catalog/database/redisenterprise-database-plugin command=vault-plugin-database-redis-enterprise_0.1.3_linux_amd64 sha256=739421599adfe3cdc53c8d6431a3066bfc0062121ba8c9c68e49119ab62a5759
```
#### Create database configurations in vault
Using the information from the getClusterUnPw.sh script from above and using the username and password valued for redis enterprise cluster authentication.   For additional explanations peruse [Hashicorp Vault plugin on Redis Enterprise k8s](https://github.com/RedisLabs/vault-plugin-database-redis-enterprise/blob/main/docs/guides/using-the-plugin-on-k8s.md)
```bash
chmod 755 /usr/local/libexec/vault/vault-plugin-database-redis-enterprise_0.1.3_linux_amd64
vault secrets enable database
vault write database/config/demo-rec-redis-enterprise-database plugin_name="redisenterprise-database-plugin" url="https://rec.demo.svc:9443" allowed_roles="*" database=redis-enterprise-database username=demo@redislabs.com password=vubYurxK
vault write database/config/demo-rec-redis-meta plugin_name="redisenterprise-database-plugin" url="https://rec.demo.svc:9443" allowed_roles="*" database=redis-meta username=demo@redislabs.com password=vubYurxK
```
#### Create database roles
```bash
vault write database/roles/redis-enterprise-database db_name=demo-rec-redis-enterprise-database creation_statements="{\"role\":\"DB Member\"}" default_ttl=3m max_ttl=10m
vault write database/roles/redis-meta db_name=demo-rec-redis-meta creation_statements="{\"role\":\"DB Member\"}" default_ttl=3m max_ttl=10m
vault read database/creds/redis-enterprise-database
      Key                Value
      ---                -----
      lease_id           database/creds/redis-enterprise-database/JVsEvOrtZfK46dMO7GWRxjTW
      lease_duration     3m
      lease_renewable    true
      password           blZxlE10AS-zy-UBbjdh
      username           v_root_redis-enterprise-database_sruv9v0fewy2rv4m1oxq_1646252982
```
#### test the database connections
Using the information from getDatabasePw.sh above.  Read the authentication parameters and use the returned values for subsequent authentication step, substituting returned values for the password and port
Grab another new terminal window to runt the port forward command.  (note, need the actual port from getDatabasePw.sh)
NOTE:  the lower redis-cli command is using the username and password from the output of the read database command.  Hurry, only 3 minutes 
before username and password expire
```bash
kubectl port-forward -n demo service/redis-enterprise-database 18154:18154
```
Open yet another new terminal window 
```bash
redis-cli -p 18154
>AUTH v_root_redis-enterprise-database_sruv9v0fewy2rv4m1oxq_1646252982 blZxlE10AS-zy-UBbjdh
vault read database/creds/redis-meta
      Key                Value
      ---                -----
      lease_id           database/creds/redis-meta/iahGKJ9XNkisGsyLgW89Ohpt
      lease_duration     3m
      lease_renewable    true
      password           Vfo2ajqBvWAVKFyI-ojR
      username           v_root_redis-meta_n2dkafecjttws9mzj9eg_1646411445
      kubectl port-forward -n demo service/redis-meta 18632:18632
redis-cli -p 18632
>AUTH v_root_redis-meta_n2dkafecjttws9mzj9eg_1646411445 Vfo2ajqBvWAVKFyI-ojR
```
#### Authorize kubernetes
* using vault terminal connection...   (if doensn't work, repeat some steps)
```bash
vault auth enable kubernetes
vault secrets enable kubernetes
vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```
* don't log out of vault, keep vault connection in a separate terminal and use the vault terminal as directed
### Install Kubegres
Based on the instructions so also read these as steps are performed for deeper explanation [Kubegres getting started](https://www.kubegres.io/doc/getting-started.html)
This creates, kubegres, create configmap to enable postgres replication, add postgres database and password, and create the one node database
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
kubectl postgres_cdc.sql mypostgres-1-0:/
kubectl exec --stdin --tty  mypostgres-1-0 -- /bin/sh
psql -Upostgres -W
create database "RedisConnect";
\c "RedisConnect"
\i postgres_cdc.sql
```

### Redis Connect
* create service account and namespace
```bash
cd $REDIS_CONNECT
kubectl create sa redis-connect* create redis-connect namespace
kubectl create namespace redis-connect
kubectl config set-context --current --namespace=redis-connect
```
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
    default_ttl="5m" \
    max_ttl="5m"
```
* authorize all the databases in kubernetes with the vault connection
```bash
vault policy write redis-enterprise-database - <<EOF
 path "database/creds/redis-enterprise-database" {
   capabilities = ["read"]
 }
EOF
vault policy write redis-connect-policy - <<EOF
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


#### Edit redis-connect files
* Edit the env.yml file for redis and postgres connections.  The urls are edited for all the connections (redis and postgres).  The postgres connection is a replacement.   File samples below:
```bash
cd $SAMPLES
```
* edit JobConfig.yml to set ```metricsEnabled: true```
* edit env.yml as below
```text
#env.yml
connections:
  - id: jobManagerConnection #Redis Connect Job Metadata connection
    type: Redis
    url: redis://redis-meta.demo.svc:15871 #this is based on lettuce uri syntax
    jobmanager.username: ${REDISCONNECT_JOBMANAGER_USERNAME} #this can be overridden by an env variable or a property file
    jobmanager.password: ${REDISCONNECT_JOBMANAGER_PASSWORD} #this can be overridden by an env variable or a property file
    #credentials.file.path: <path to <redisconnect_credentials_jobmanager_<job_name> e.g. /var/secrets/jobmanager> when username and password are not provided here
  - id: targetConnection #target Redis connection
    type: Redis
    url: redis://redis-enterprise-database.demo.svc:18154 #this is based on lettuce uri syntax
    target.username: ${REDISCONNECT_TARGET_USERNAME} #this can be overridden by an env variable or a property file
    target.password: ${REDISCONNECT_TARGET_PASSWORD} #this can be overridden by an env variable or a property file
    #credentials.file.path: <path to <redisconnect_credentials_redis_<job_name> e.g. /var/secrets/redis> when username and password are not provided here
  - id: RDBConnection
    type: RDB
    name: RedisConnect #database pool name
    database: RedisConnect #database
    url: "jdbc:postgresql://mypostgres.postgres.svc:5432/RedisConnect" #this is jdbc client driver specific, and it can contain any supported parameters
    host: mypostgres.postgres.svc
    port: 5432
    # source.username: ${REDISCONNECT_SOURCE_USERNAME} #this can be overridden by an env variable or a property file
    # source.password: ${REDISCONNECT_SOURCE_PASSWORD} #this can be overridden by an env variable or a property file
    credentials.file.path: "/vault/secrets/postgresql"
``` 
```bash
cp -p ../../logback.xml .
kubectl create configmap redis-connect-postgres-config \
  --from-file=JobConfig.yml=JobConfig.yml \
  --from-file=JobManager.yml=JobManager.yml \
  --from-file=env.yml=env.yml \
  --from-file=Setup.yml=Setup.yml \
  --from-file=mapper1.yml=mappers/mapper1.yml \
  --from-file=logback.xml=logback.xml 
```
```bash
cd $RC_VAULT
```
* edit redis-connect-postgres-stage.yaml replacing existing top of the file with this changed content
```text
apiVersion: batch/v1
kind: Job
metadata:
  name: redis-connect-postgres-stage # deployment name
  labels:
    app: redis-connect-postgres-stage # deployment label
spec:
  backoffLimit: 10 # try this many times before declaring failure
  template: # pod template
    metadata:
      labels:
        app: redis-connect-postgres-stage
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-pre-populate-only: "true"
        vault.hashicorp.com/role: "redis-connect"
        vault.hashicorp.com/secret-volume-path: "/vault/secrets/postgresql"
        vault.hashicorp.com/agent-inject-file-redis-connect: "redisconnect_credentials_postgresql_postgres-job"
        vault.hashicorp.com/agent-inject-secret-redis-connect: 'database/creds/redis-connect'
        vault.hashicorp.com/agent-inject-template-redis-connect: |
          {{ with secret "database/creds/redis-connect" -}}
          source.username={{ .Data.username }}
          source.password={{ .Data.password }}
          {{- end }}
```
* further down, on redis-connect-postgres-stage.yaml, make this edit to add the four redis connect environment variables:  REDISCONNECT_JOBMANAGER_USERNAME, REDISCONNECT_JOBMANAGER_PASSWORD, REDISCONNECT_TARGET_USERNAME, REDISCONNECT_TARGET_PASSWORD
  * NOTE:  originally code was set up to have an ACL with username and password but it will accept a null username which works best in this situation
```text
        env:
          - name: REDISCONNECT_LOGBACK_CONFIG
            value: "/opt/redislabs/redis-connect-postgres/config/logback.xml"
          - name: REDISCONNECT_CONFIG
            value: "/opt/redislabs/redis-connect-postgres/config/fromconfigmap"
          - name: REDISCONNECT_REST_API_ENABLED
            value: "false"
          - name: REDISCONNECT_REST_API_PORT
            value: "8282"
          - name: REDISCONNECT_JAVA_OPTIONS
            value: "-Xms256m -Xmx1g"
          - name: REDISCONNECT_JOBMANAGER_USERNAME
            value: ""
          - name: REDISCONNECT_JOBMANAGER_PASSWORD
            value: "FW2mFXEH"
          - name: REDISCONNECT_TARGET_USERNAME
            value: ""
          - name: REDISCONNECT_TARGET_PASSWORD
            value: "DrCh7J31"
```
* In redis-connect-postgres-start.yaml, replace the top section with this content
```text
spec:
  replicas: 2 # replicas for HA
  selector:
    matchLabels:
      app: redis-connect-postgres # which pods is the deployment managing, as defined by the pod template
  template: # pod template
    metadata:
      labels:
        app: redis-connect-postgres
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "redis-connect"
        vault.hashicorp.com/secret-volume-path: "/vault/secrets/postgresql"
        vault.hashicorp.com/agent-inject-file-redis-connect: "redisconnect_credentials_postgresql_postgres-job"
        vault.hashicorp.com/agent-inject-secret-redis-connect: 'database/creds/redis-connect'
        vault.hashicorp.com/agent-inject-template-redis-connect: |
          {{ with secret "database/creds/redis-connect" -}}
          source.username={{ .Data.username }}
          source.password={{ .Data.password }}
          {{- end }}
```
* further down, on redis-connect-postgres-start.yaml, make this edit to add the four redis connect environment variables:  REDISCONNECT_JOBMANAGER_USERNAME, REDISCONNECT_JOBMANAGER_PASSWORD, REDISCONNECT_TARGET_USERNAME, REDISCONNECT_TARGET_PASSWORD
  * NOTE:  originally code was set up to have an ACL with username and password but it will accept a null username which works best in this situation
```text
        env:
          - name: REDISCONNECT_LOGBACK_CONFIG
            value: "/opt/redislabs/redis-connect-postgres/config/logback.xml"
            # value: "/opt/redislabs/redis-connect-postgres/config/fromconfigmap/logback.xml"
          - name: REDISCONNECT_CONFIG
            value: "/opt/redislabs/redis-connect-postgres/config/fromconfigmap"
          - name: REDISCONNECT_REST_API_ENABLED
            value: "false"
          - name: REDISCONNECT_REST_API_PORT
            value: "8282"
          - name: REDISCONNECT_JAVA_OPTIONS
            value: "-Xms256m -Xmx1g -Dcredentials.rotation.eventlistener.enabled=true"
          - name: REDISCONNECT_JOBMANAGER_USERNAME
            value: ""
          - name: REDISCONNECT_JOBMANAGER_PASSWORD
            value: "FW2mFXEH"
          - name: REDISCONNECT_TARGET_USERNAME
            value: ""
          - name: REDISCONNECT_TARGET_PASSWORD
            value: "DrCh7J31"
```
* Stage the redis-connect job
```bash
kubectl apply -f redis-connect-postgres-stage.yaml
```
* Start the redis-connect job
```bash
kubectl apply -f redis-connect-postgres-start.yaml
```
* Redis-connect job [documentation link](https://github.com/redis-field-engineering/redis-connect-dist/tree/main/connectors/postgres/demo#start-redis-connect-postgres-connector)
* look for resulting rows in redis enterprise using redisinsight (see directions above)
* There are multiple methods to debug the running job.  Here are a few:
  * Find the pod name(s) for redis connect
  * get the logs for init and main container
  * log in to the pod and look at log files 
  * test the postgresql connection
```bash
kubectl get pods
kubectl logs redis-connect-postgres-595d6fb5f4-54c6v -c vault-agent-init
kubectl logs redis-connect-postgres-595d6fb5f4-54c6v -c redis-connect-postgres
kubectl  exec --stdin=true --tty=true pod/redis-connect-postgres-595d6fb5f4-54c6v -- /bin/sh
cd logs
# investigate the log files 
vi *
# login to cli
cd ../bin
./redisconnect.sh cli
> validate connection -t JDBCConnectionProvider -i RDBConnection
```
