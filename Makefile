VERSION ?= $(shell cat .version)
REGISTRY ?= 093527149400.dkr.ecr.us-west-2.amazonaws.com

build:
	docker build -t $(REGISTRY)/riak-kv:$(VERSION)-2.2.3 -f Dockerfile .
	docker push $(REGISTRY)/riak-kv:$(VERSION)-2.2.3
