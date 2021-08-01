export GO111MODULE=on
DOCKER_IMAGE?=deploy-service:${VERSION}

all: lint test install

install:
	@echo "building and installing..."
	@GOOS=${GOOS} CGO_ENABLED=${CGO_ENABLED} GOARCH=${GOARCH} go install --installsuffix cgo --ldflags="-w  -s" ${GOMODFLAG} ./cmd/$*

build: 
	@echo "building..."
	@go build ${GOMODFLAG} ${PACKAGES}

docker-image:
	echo "Building docker image: ${DOCKER_IMAGE}"
	docker build -t ${DOCKER_IMAGE} -f Dockerfile ${PWD}
	docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_LATEST}

.PHONY: test
test: lint
	go test -coverprofile=coverage.txt -covermode=atomic -race ./...

.PHONY: lint
lint: check-format vet
	go get golang.org/x/lint/golint
	golint -set_exit_status=1 ./...

.PHONY: lint-local
lint-local: lint
	golangci-lint run

.PHONY: vet
vet:
	go vet ./...

.PHONY: check-format
check-format:
	@echo "Running gofmt..."
	$(eval unformatted=$(shell find . -name '*.go' | grep -v ./.git | grep -v vendor | xargs gofmt -l))
	$(if $(strip $(unformatted)),\
		$(error $(\n) Some files are not formatted properly! Run: \
			$(foreach file,$(unformatted),$(\n)    gofmt -w $(file))$(\n)),\
		@echo All files are well formatted.\
	)

.PHONY: install-ci
install-ci:
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(GOPATH)/bin v1.32.0
