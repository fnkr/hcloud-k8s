.DELETE_ON_ERROR:
.PHONY: all
all: ingress-nginx.yaml

ingress-nginx.yaml:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm template kube-ingress-nginx ingress-nginx/ingress-nginx --version 3.36.0 -n kube-ingress-nginx -f values.yaml | cat > ingress-nginx.yaml

clean:
	rm -f ingress-nginx.yaml
