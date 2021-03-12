.DELETE_ON_ERROR:
.PHONY: all init
all: init cilium.yaml cilium-ipsec.yaml

init:
	helm repo add cilium https://helm.cilium.io
	helm repo update

cilium.yaml:
	helm template cilium cilium/cilium --version 1.9.4 -n kube-system -f values.yaml > cilium.yaml

cilium-ipsec.yaml:
	helm template cilium cilium/cilium --version 1.9.4 -n kube-system -f values.yaml -f values-ipsec.yaml > cilium-ipsec.yaml

clean:
	rm -f cilium.yaml cilium-ipsec.yaml
