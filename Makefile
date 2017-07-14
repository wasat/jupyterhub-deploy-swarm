# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

include .env

.DEFAULT_GOAL=build

network:
	@docker network inspect $(SWARMSPAWNER_NETWORK) >/dev/null 2>&1 || docker network  create --attachable -d overlay $(SWARMSPAWNER_NETWORK)

volumes:
	@docker volume inspect $(JUPYTERHUB_DATA_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(JUPYTERHUB_DATA_VOLUME_HOST)

self-signed-cert:
	# make a self-signed cert

secrets/jupyterhub.crt:
	@echo "Need an SSL certificate in secrets/jupyterhub.crt"
	@exit 1

secrets/jupyterhub.key:
	@echo "Need an SSL key in secrets/jupyterhub.key"
	@exit 1

userlist:
	@echo "Add usernames, one per line, to ./userlist, such as:"
	@echo "    zoe admin"
	@echo "    wash"
	@exit 1

# Do not require cert/key files if SECRETS_VOLUME defined
secrets_volume = $(shell echo $(SECRETS_VOLUME))
ifeq ($(secrets_volume),)
	cert_files=secrets/jupyterhub.crt secrets/jupyterhub.key
else
	cert_files=
endif

check-files: userlist $(cert_files)

pull:
	docker pull $(SWARMSPAWNER_NOTEBOOK_IMAGE)

build_notebook_image:
	docker build -t walki12/jupyternotebook -f Dockerfile.notebook .

notebook_image: pull

build: check-files network volumes
	docker-compose build
	docker push walki12/jupyterhub

push:
	docker push walki12/jupyterhub

.PHONY: network volumes check-files pull notebook_image build_notebook_image build push
