#Vault Key Value
# Basic

## Writing a Secret

```bash
vault kv put secret/hello foo=world
```

## Getting a Secret

```bash
vault kv get secret/hello
```

## Delete a Secret

```bash
vault kv delete secret/hello
```

read and write arbitrary secrets to Vault. You may have noticed all requests started with secret/
prefix `secret` tells Vault which secrets engine to which it should route traffic (longest prefix match)

default, Vault enables a secrets engine called kv at the path secret/ The kv secrets engine reads and writes raw data to the backend storage

## Enable a Secrets Engine

```bash
vault secrets enable -path=kv kv
#alternative equal
vault secrets enable kv # default path = name of secret
```

## check secrets list

```bash
vault secrets list
```

`Note: sys/ path corresponds to the system backend Many of these operations interact with Vault's core system and are not required for beginners`

## List secret

```bash
vault write kv/my-secret value="s3c(eT"
vault write kv/hello target=world
vault write kv/airplane type=boeing class=787
vault list kv
```

## Disable secret engine

```bash
vault secrets disable kv/
```

