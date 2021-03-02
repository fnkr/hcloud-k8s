.DELETE_ON_ERROR:
.PHONY: all init
all: init cilium.yaml

init:
	helm repo add cilium https://helm.cilium.io
	helm repo update

cilium.yaml:
	helm template cilium cilium/cilium --version 1.7.1 -n kube-system -f values.yaml > cilium.yaml
	sed -i -E 's/(enable-remote-node-identity: "true")/\1\n  blacklist-conflicting-routes: "false"/' cilium.yaml

clean:
	rm -f cilium.yaml
