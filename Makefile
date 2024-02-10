#!/usr/bin/env make

Resources = $(wildcard *.yaml)

cluster:
	@if ! docker ps | grep -q "local-registry"; then \
		docker run -d -p 5000:5000 --restart=always --name local-registry registry:2; \
	fi
	@kind create cluster --name blank --config ./kind_config.yml || true
	@docker network connect kind local-registry || true
	@kubectl apply -f ./kind_configmap.yml

validate:
	@kubectl get nodes

resources:
	@for file in $(Resources); do \
		kubectl apply -f $$file; \
	done

clean:
	@docker stop local-registry || true
	@docker rm local-registry || true
	@kind delete cluster --name blank

all: cluster validate resources

.PHONY: cluster validate resources clean all
