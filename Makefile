# Concise introduction to GNU Make:
# https://swcarpentry.github.io/make-novice/reference.html
include .env

# Taken from https://www.client9.com/self-documenting-makefiles/
help : ## Print this help
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)
.PHONY : help
.DEFAULT_GOAL := help

variables : ## Print value of variables
	@echo NAME: ${NAME}
	@echo RELEASE: ${RELEASE}
.PHONY : name

setup : ## Set up git handling
	@pre-commit install --hook-type precommit --hook-type commit-msg
.PHONY : setup

# --------------------- #
# Interface with Docker #
# --------------------- #

# To debug errors during build add `--progress plain \` to get additional
# output.
build : ## Build image with name `${NAME}`, for example, `make build`
	DOCKER_BUILDKIT=1 \
	docker build \
		--tag localbuild/${NAME} \
		--pull \
		--build-arg RELEASE=${RELEASE} \
		--load \
		.
.PHONY : build

# --------------------- #
# Interface with GitHub #
# --------------------- #

release : ## Release with `${RELEASE}`, for example, `make release`
	@[[ -z $$(git status -s) ]] || (echo "Release should only be performed on a clean git tree"; exit 1)
	@if [ $$(git tag -l ${RELEASE}) ]; then \
		git tag -d ${RELEASE}; \
		git push origin :${RELEASE}; \
	fi
	@git tag ${RELEASE};
	@git push origin ${RELEASE};
	@git fetch --tags;

.PHONY : release
