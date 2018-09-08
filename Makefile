IMAGE = opolis/peregrine:dev

RUN = docker run -it \
	  -v $(PWD):/src \
	  -p 8080:8080 \
	  $(IMAGE)

GANACHE = ganache-cli \
	--accounts 3 \
	--blockTime 5 \
	--host 0.0.0.0 \
	--gasPrice 0 \
	--seed 0

.PHONY: image
image:
	@docker build -t $(IMAGE) .

.PHONY: dev
dev:
	@$(RUN) npm run dev

.PHONY: deps
deps:
	$(RUN) npm run reinstall

.PHONY: shell
shell:
	@$(RUN) bash

.PHONY: ganache
ganache:
	@$(GANACHE)
