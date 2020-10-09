SHELL:=/bin/bash
TERRAFORM_VERSION=0.12.28
TERRAFORM=docker run --rm -v "${PWD}:/work" -v "${HOME}:/root" -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) -e http_proxy=$(http_proxy) --net=host -w /work hashicorp/terraform:$(TERRAFORM_VERSION)

TERRAFORM_DOCS=docker run --rm -v "${PWD}:/work" tmknom/terraform-docs

CHECKOV=docker run --rm -t -v "${PWD}:/work" bridgecrew/checkov

TFSEC=docker run --rm -it -v "${PWD}:/work" liamg/tfsec

DIAGRAMS=docker run -t -v "${PWD}:/work" figurate/diagrams python

EXAMPLE=$(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

.PHONY: all clean validate test docs format

all: validate test docs format

clean:
	rm -rf .terraform/

validate:
	$(TERRAFORM) init && $(TERRAFORM) validate && \
		$(TERRAFORM) init modules/daemon && $(TERRAFORM) validate modules/daemon
		$(TERRAFORM) init modules/default && $(TERRAFORM) validate modules/default
		$(TERRAFORM) init modules/fargate && $(TERRAFORM) validate modules/fargate

test: validate
	$(CHECKOV) -d /work && \
		$(CHECKOV) -d /work/modules/daemon && \
		$(CHECKOV) -d /work/modules/default && \
		$(CHECKOV) -d /work/modules/fargate

	$(TFSEC) /work && \
		$(TFSEC) /work/modules/daemon && \
		$(TFSEC) /work/modules/default && \
		$(TFSEC) /work/modules/fargate

diagram:
	$(DIAGRAMS) diagram.py

docs: diagram
	$(TERRAFORM_DOCS) markdown ./ >./README.md && \
		$(TERRAFORM_DOCS) markdown ./modules/daemon >./modules/daemon/README.md
		$(TERRAFORM_DOCS) markdown ./modules/default >./modules/default/README.md
		$(TERRAFORM_DOCS) markdown ./modules/fargate >./modules/fargate/README.md

format:
	$(TERRAFORM) fmt -list=true ./ && \
		$(TERRAFORM) fmt -list=true ./modules/daemon && \
		$(TERRAFORM) fmt -list=true ./modules/default && \
		$(TERRAFORM) fmt -list=true ./modules/fargate && \
		$(TERRAFORM) fmt -list=true ./examples/nginx

example:
	$(TERRAFORM) init examples/$(EXAMPLE) && $(TERRAFORM) plan -input=false examples/$(EXAMPLE)
