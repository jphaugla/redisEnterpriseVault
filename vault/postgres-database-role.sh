vault write database/roles/redis-connect \
    db_name=kube-postgres \
    creation_statements="CREATE ROLE \"{{name}}\" WITH REPLICATION LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
         GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; \
         ALTER USER \"{{name}}\" WITH SUPERUSER;" \
    default_ttl="60m" \
    max_ttl="60m"
