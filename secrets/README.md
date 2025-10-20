# Kubernetes Secrets

Kubernetes Secrets are objects that help you store and manage sensitive information, such as passwords, OAuth tokens, SSH keys, and other confidential data that should not be stored in clear text in your Pod specifications or container images.

## Table of Contents

- [Overview](#overview)
- [Types of Secrets](#types-of-secrets)
- [Creating Secrets](#creating-secrets)
  - [Using YAML](#using-yaml)
  - [Using kubectl](#using-kubectl)
- [Using Secrets](#using-secrets)
  - [As Environment Variables](#as-environment-variables)
  - [As Volumes](#as-volumes)
- [Security Considerations](#security-considerations)
- [Best Practices](#best-practices)
- [Examples](#examples)

## Overview

Secrets allow you to separate sensitive information from your application code, making your applications more secure and portable. When working with applications that require sensitive data like API keys or database credentials, Secrets are the appropriate Kubernetes resource to use.

## Types of Secrets

Kubernetes supports several types of secrets:

- `Opaque`: Default Secret type, arbitrary user-defined data (most commonly used)
- `kubernetes.io/service-account-token`: Service account token
- `kubernetes.io/dockercfg`: Serialized ~/.dockercfg file
- `kubernetes.io/dockerconfigjson`: Serialized ~/.docker/config.json file
- `kubernetes.io/basic-auth`: Basic authentication credentials
- `kubernetes.io/ssh-auth`: SSH credentials
- `kubernetes.io/tls`: TLS credentials
- `bootstrap.kubernetes.io/token`: Bootstrap token data

## Creating Secrets

### Using YAML

You can create a Secret by defining it in a YAML file. However, you need to encode sensitive data in base64 format.

Example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: default
type: Opaque
data:
  username: YWRtaW4=  # 'admin' in base64
  password: UEAkJHcwcmQ=  # 'P@$$w0rd' in base64
```

Apply the Secret:

```bash
kubectl apply -f secret.yaml
```

### Using kubectl

You can create a Secret directly with kubectl:

```bash
# From literal values
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=P@$$w0rd

# From files
kubectl create secret generic ssl-certificate \
  --from-file=tls.crt=/path/to/tls.crt \
  --from-file=tls.key=/path/to/tls.key
```

## Using Secrets

### As Environment Variables

You can use Secrets as environment variables in your Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: DATABASE_USER
        valueFrom:
          secretKeyRef:
            name: db-credentials
            key: username
      - name: DATABASE_PASSWORD
        valueFrom:
          secretKeyRef:
            name: db-credentials
            key: password
```

### As Volumes

You can mount Secrets as volumes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/secret-data"
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-credentials
```

Each key in the Secret becomes a file in the mounted directory. In this example, `/etc/secret-data/username` and `/etc/secret-data/password` will be created.

## Security Considerations

1. **Secrets are stored in etcd**: By default, they are stored unencrypted in the API server's underlying data store (etcd). Consider enabling encryption at rest for etcd.

2. **Base64 encoding is not encryption**: Base64 is an encoding, not encryption. Anyone with access to your YAML files can decode these values.

3. **Secret propagation**: Secrets are only sent to nodes that have pods requiring them.

4. **In-memory storage**: On the node, Secrets are stored in tmpfs volumes (RAM-backed filesystem) to avoid writing to disk.

## Best Practices

1. **Enable encryption at rest** for etcd to protect your Secrets.

2. **Use RBAC** to restrict which users and system components can access Secrets.

3. **Never commit Secret YAML files** to version control systems.

4. **Rotate Secrets regularly**, especially for high-value credentials.

5. **Consider using external secret management systems** like HashiCorp Vault, AWS Secrets Manager, or Azure Key Vault with appropriate Kubernetes integrations.

6. **Limit Secret size** to less than 1MB (Kubernetes limitation).

7. **Use specific Secret types** when applicable (e.g., TLS, BasicAuth) instead of the generic Opaque type.

## Examples

See [secret-example.yaml](./secret-example.yaml) for a complete example of a Kubernetes Secret.

To encode values to base64:

```bash
echo -n 'admin' | base64
# YWRtaW4=

echo -n 'P@$$w0rd' | base64
# UEAkJHcwcmQ=
```

To decode base64 values:

```bash
echo 'YWRtaW4=' | base64 --decode
# admin
```

To view all Secrets in the current namespace:

```bash
kubectl get secrets
```

To view the details of a specific Secret:

```bash
kubectl describe secret db-credentials
```

To extract the values from a Secret:

```bash
kubectl get secret db-credentials -o jsonpath='{.data.username}' | base64 --decode
# admin
```