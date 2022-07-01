# home directory for all github repositories
export GITREPO_HOME=~/gits
# home repository for Redis Enterprise k8s integrated with Vault, postresql, and redis-connect
export GIT_ENTERPRISE_REDIS_VAULT=$GITREPO_HOME/redisEnterpriseVault
# each of these subdirectories will be names after their kubernetes namespace
#  demo is used because the redis enterprise k8s instructions use demo as default namespace
# kubernetes subdirectory in redisEnterpriseVault 
export DEMO=$GIT_ENTERPRISE_REDIS_VAULT/demo
# vault subdirectory in redisEnterpriseVault 
export VAULT=$GIT_ENTERPRISE_REDIS_VAULT/vault
# postgres subdirectory in redisEnterpriseVault 
export POSTGRES=$GIT_ENTERPRISE_REDIS_VAULT/postgres
# redis-connect subdirectory in redisEnterpriseVault 
export REDIS_CONNECT=$GIT_ENTERPRISE_REDIS_VAULT/redis-connect
# other important repositories
export GIT_REDIS_CONNECT=$GITREPO_HOME/redis-connect-dist
export GIT_REDIS_CONNECT_PG=$GIT_REDIS_CONNECT/examples/postgres
export GIT_RE_K8S=$GITREPO_HOME/redis-enterprise-k8s-docs
export GIT_VAULT_PLUGIN=$GITREPO_HOME/vault-plugin-database-redis-enterprise
# redis-connect samples
export SAMPLES=$GIT_REDIS_CONNECT_PG/demo/
# redis-connect vault
export RC_VAULT=$GIT_REDIS_CONNECT_PG/k8s-docs/vault
