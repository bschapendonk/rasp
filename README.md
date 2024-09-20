# rasp "ripe-atlas-software-probe"

Inspired by https://github.com/CTassisF/ripe-atlas-alpine, which was lacking some thigs for me

* rootless
* daily updates for the base image

# How to deploy

## Kubernetes, using Kustomize

There is an example deployment in the `deploy/` folder

* Create a ssh key using `ssh-keygen -f probe_key -C atlas-probe`, this will be used by the kustomization to create a secret.
* Then run `kubectl apply -k .`, this wil apply `kustomization.yaml` in the namespace `rasp`.
* Register your probe using the public key
