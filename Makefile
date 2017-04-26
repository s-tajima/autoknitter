ARCH:=linux_amd64
PACKER_VERSION:=1.0.0

DISTRIBUTION=centos
OS_VERSION=6.9

setup:
	mkdir -p ./tmp/ ./bin/
	rm -rf ./bin/*
	wget -nc -P ./tmp/ "https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_$(ARCH).zip"
	unzip -d bin/ tmp/packer_$(PACKER_VERSION)_$(ARCH).zip

build:
	./bin/packer build \
		-var-file ./variables.json \
		-var-file ./resources/$(DISTRIBUTION)/$(OS_VERSION)/variables.json \
		-var 'script_name=./resources/$(DISTRIBUTION)/$(OS_VERSION)/_bootstrap.sh' \
		-var 'resource_dir=./resources/$(DISTRIBUTION)/$(OS_VERSION)/artifacts/' \
		./template.json

