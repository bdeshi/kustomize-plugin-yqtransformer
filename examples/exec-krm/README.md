# Exec Plugin Example

This example runs `YqTransformer` as an **exec KRM function**.

## Locate the plugin executable

The `config.kubernetes.io/function` annotation in `yq-transformer.yaml`
points to the plugin's executable path in the `exec.path` key.
This path is relative to `kustomization.yaml` and can be anywhere on disk.

## Build with alpha plugins and exec enabled

```bash
kustomize build --enable-alpha-plugins --enable-exec .
```

You should see a label `environment: dev` added to one of the Deployments.
