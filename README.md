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
* [Setup](#setup)
* [Configure](#configure)
* [Usage](#usage)
* [Available distributions, versions](#available-distributions-versions)
* [License](#license)

## Concepts

* Helper for build Amazon Machine Image automatically from scratch.
* Using Packer, EBS Surrogate Builder.

## Requirements

* make

## Setup

```
$ git clone git@github.com:s-tajima/autoknitter.git
$ make setup
```

## Configure

* Prepare AWS environment for Packer.
    * refs: https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials
* Prepare variables file.
    ```
    $ cp variables.json.sample variables.json # and edit this.
    ```

## Usage

```
$ make build
```

## Available distributions, versions

* CentOS 6.9
* (Planning to add more...)

## License

[MIT](./LICENSE)

## Author

[Satoshi Tajima](https://github.com/s-tajima)
