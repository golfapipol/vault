# Create Data Container
docker create -v /config --name config busybox; docker cp vault.hcl config:/config/;
# Launch Consul Agent
docker run -d --name consul \
     -p 8500:8500 \
    consul:v0.6.4 \
    agent -dev -client=0.0.0.0
# Launch Vault server
docker run -d --name vault-dev \
  --link consul:consul \
  -p 8200:8200 \
  --volumes-from config \
  cgswong/vault:0.5.3 server -config=/config/vault.hcl

#alias command vault
alias vault='docker exec -it vault-dev vault "$@"'
#export environment
export VAULT_ADDR=http://127.0.0.1:8200
vault init -address=${VAULT_ADDR} > keys.txt

# Unseal Vault (Unsealing is the process of constructing the master key necessary to read the decryption key to decrypt the data, allowing read access to the Vault.)
vault unseal -address=${VAULT_ADDR} $(grep 'Key 1:' keys.txt | awk '{print $NF}')
vault unseal -address=${VAULT_ADDR} $(grep 'Key 2:' keys.txt | awk '{print $NF}')
vault unseal -address=${VAULT_ADDR} $(grep 'Key 3:' keys.txt | awk '{print $NF}')

vault status -address=${VAULT_ADDR}
# Get token
export VAULT_TOKEN=$(grep 'Initial Root Token:' keys.txt | awk '{print substr($NF, 1, length($NF)-1)}')
vault auth -address=${VAULT_ADDR} ${VAULT_TOKEN}

# Save Data
vault write -address=${VAULT_ADDR} secret/api-key value=12345678
# Read Data
vault read -address=${VAULT_ADDR} secret/api-key

# API 
curl -H "X-Vault-Token:$VAULT_TOKEN" \
  -XGET http://docker:8200/v1/secret/api-key
# pipe with jq
curl -s -H  "X-Vault-Token:$VAULT_TOKEN" \
  -XGET http://docker:8200/v1/secret/api-key \
  | jq -r .data.value

# LibSecret (3rd Party Volume Driver) for plugin access
nohup docker-volume-libsecret \
  --addr $VAULT_ADDR \
  --backend vault \
  --store-opt token=$VAULT_TOKEN </dev/null &> libsecretlogs &

# start libsecret
docker run -ti --rm \
  --volume-driver libsecret \
  -v secret/app-1/:/secrets \
  alpine ash

# read only
cat secrets/api-key