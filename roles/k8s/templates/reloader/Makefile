.DELETE_ON_ERROR:
.PHONY: all
all: reloader.yaml

reloader.yaml:
	helm repo add stakater https://stakater.github.io/stakater-charts
	helm repo update
	helm template reloader stakater/reloader -n kube-reloader -f values.yaml | cat > reloader.yaml

clean:
	rm -f reloader.yaml
