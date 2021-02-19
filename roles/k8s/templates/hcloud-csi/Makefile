.DELETE_ON_ERROR:
.PHONY: all
all: hcloud-csi.yaml

hcloud-csi.yaml:
	curl -fsSL -o hcloud-csi.yaml https://github.com/hetznercloud/csi-driver/raw/master/deploy/kubernetes/hcloud-csi.yml

clean:
	rm -f hcloud-csi.yaml
