# Dynamic Secrets

Unlike the kv secrets where you had to put data into the store yourself, dynamic secrets are generated when they are accessed. Dynamic secrets do not exist until they are read, so there is no risk of someone stealing them or another client using the same secrets. Because Vault has built-in revocation mechanisms, dynamic secrets can be revoked immediately after use, minimizing the amount of time the secret existed.

## Enable the AWS Secrets Engine

```bash
vault secrets enable -path=aws aws
```

## Configure the AWS Secrets Engine

```bash
vault write aws/config/root \
    access_key=AKIAI4SGLQPBX6CSENIQ \
    secret_key=z1Pdn06b3TnpG+9Gwj3ppPSOlAsu08Qw99PUW+eB \
    region=us-east-1
```

`Warning: Do not use your root account keys in production. This is a getting started guide and is not a best practices guide for production installations.`

## Create a Role

```bash
#           aws/roles/:name
vault write aws/roles/my-role \
        credential_type=iam_user \
        policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
```

## Generating the Secret
vault read aws/creds/my-role

# Revoke the Secret
vault lease revoke aws/creds/my-role/0bce0782-32aa-25ec-f61d-c026ff22106