VERSION ?= $(shell cat .version)

build:
	docker build -t pyalex/riak-kv:$(VERSION)-2.2.0 -f Dockerfile .
	docker push pyalex/riak-kv:$(VERSION)-2.2.0

