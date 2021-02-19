.DELETE_ON_ERROR:
.PHONY: all
all: cilium.yaml

cilium.yaml:
	curl -fsSL -o cilium.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/raw/master/e2etests/templates/cilium.yml

clean:
	rm -f cilium.yaml
