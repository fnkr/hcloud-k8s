.DELETE_ON_ERROR:
.PHONY: all
all: hcloud-ccm.yaml

hcloud-ccm.yaml:
	curl -fsSL -o hcloud-ccm.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/raw/master/deploy/ccm-networks.yaml
	sed -i 's:10.244.0.0/16:{{ k8s_ip_range_pod }}:' hcloud-ccm.yaml

clean:
	rm -f hcloud-ccm.yaml
