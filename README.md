# rasp ["ripe-atlas-software-probe"](https://github.com/RIPE-NCC/ripe-atlas-software-probe)

Inspired by https://github.com/CTassisF/ripe-atlas-alpine.

Most notable changes:
* Focus on kubernetes / kustomize
* Rootless container
* Daily builds using GitHub Actions

## How to deploy on kubernetes using kustomize

There is an example deployment in the `deploy/` folder

* Create a ssh key using `ssh-keygen -f probe_key -C atlas-probe`, the `secretGenerator` in `kustomization.yaml` will create a secret based on these files.
* Then run `kubectl apply -k .`, this wil apply `kustomization.yaml` in the namespace `rasp`.
* Register your probe using the public key.
