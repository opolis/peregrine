IMAGE = opolis/peregrine:dev

RUN = docker run -it \
	  -v $(PWD):/src \
	  $(IMAGE)

GANACHE = ganache-cli \
		  --accounts 3 \
		  --blockTime 5 \
		  --host 0.0.0.0 \
		  --gasPrice 0 \
		  --seed 0 \

.PHONY: image
image:
	@docker build -t $(IMAGE) .

.PHONY: shell
shell:
	@$(RUN) bash

.PHONY: ganache
ganache:
	@$(GANACHE)
