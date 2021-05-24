.DELETE_ON_ERROR:
.PHONY: all init
all: init cilium.yaml cilium-wireguard.yaml

init:
	helm repo add cilium https://helm.cilium.io
	helm repo update

cilium.yaml:
	helm template cilium cilium/cilium --version 1.10.0 -n kube-system -f values.yaml > cilium.yaml

cilium-wireguard.yaml:
	helm template cilium cilium/cilium --version 1.10.0 -n kube-system -f values.yaml -f values-ipsec.yaml > cilium-wireguard.yaml

clean:
	rm -f cilium.yaml cilium-wireguard.yaml
