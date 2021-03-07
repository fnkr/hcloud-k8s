.DELETE_ON_ERROR:
.PHONY: all init
all: init cilium.yaml

init:
	helm repo add cilium https://helm.cilium.io
	helm repo update

cilium.yaml:
	helm template cilium cilium/cilium --version 1.9.4 -n kube-system -f values.yaml > cilium.yaml

clean:
	rm -f cilium.yaml
