# autoknitter

Automated Amazon Machine Images (AMI) builder.

```
$ make build
./bin/packer build \
	-var-file ./variables.json \
	-var-file ./resources/centos/6.9/variables.json \
	./template.json
amazon-ebssurrogate output will be in this color.

==> amazon-ebssurrogate: Prevalidating AMI Name...

.. snip ..

Build 'amazon-ebssurrogate' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebssurrogate: AMIs were created:

ap-northeast-1: ami-XXXXXXXX
```

## Index

* [Concepts](#concepts)
* [Requirements](#requirements)
* [Installation](#installation)
* [Configure](#configure)
* [Usage](#usage)
* [License](#license)

## Concepts

* Build Amazon Machine Image automatically from scratch.
* Using Packer, EBS Surrogate Builder.

