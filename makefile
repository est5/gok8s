SHELL := /bin/zsh

run:
	go run main.go

VERSION := 1.0

all: service

service:
	docker build \
	-f zarf/docker/dockerfile \
	-t service-amd64:${VERSION} \
	--build-arg BUILD_REF=${VERSION} \
	.


KIND_CLUSTER := est-cluster
kind-up:
	kind create cluster \
	--image kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6 \
	--name ${KIND_CLUSTER} \
	--config /home/est5/Dev/serviceTemplate/gok8s/zarf/k8s/kind/kind-config.yaml

kind-down:
	kind delete cluster --name ${KIND_CLUSTER}

kind-load:
	kind load docker-image service-amd64:${VERSION} --name ${KIND_CLUSTER}

kind-apply:
	cat ~/Dev/serviceTemplate/gok8s/zarf/k8s/base/service-pod/base-service.yaml | kubectl apply -f -

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100 --namespace=service-system

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-restart:
	kubectl rollout restart deployment service-pod --namespace=service-system