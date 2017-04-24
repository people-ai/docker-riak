VERSION ?= $(shell cat .version)
REGISTRY ?= pyalex

build:
	docker build -t $(REGISTRY)/riak-kv:$(VERSION)-2.2.3 -f Dockerfile .
	docker push $(REGISTRY)/riak-kv:$(VERSION)-2.2.3

