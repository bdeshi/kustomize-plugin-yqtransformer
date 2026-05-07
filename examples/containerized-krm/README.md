# Container Plugin Example

This example runs `YqTransformer` as a **containerized KRM function**.

## Locate the plugin image

The `config.kubernetes.io/function` annotation in `yq-transformer.yaml`
points to the plugin's image address in the `container.image` key.

## Build with alpha plugins enabled

```bash
kustomize build --enable-alpha-plugins .
```

You should see a label `environment: dev` added to one of the Deployments.
