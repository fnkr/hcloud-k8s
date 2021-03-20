.DELETE_ON_ERROR:
.PHONY: all
all: cert-manager.yaml

cert-manager.yaml:
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm template cert-manager jetstack/cert-manager -n kube-cert-manager -f values.yaml > cert-manager.yaml

clean:
	rm -f cert-manager.yaml
