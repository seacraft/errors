PKGS := github.com/seacraft/errors
SRCDIRS := $(shell go list -f '{{.Dir}}' $(PKGS))
GO := go

check: test vet gofmt misspell unconvert staticcheck ineffassign unparam

test:
	$(GO) test $(PKGS)

vet: | test
	$(GO) vet $(PKGS)

staticcheck:
ifeq (,$(shell which staticcheck 2>/dev/null))
	@echo "===========> Installing staticcheck"
	$(GO) install honnef.co/go/tools/cmd/staticcheck@latest
endif
	staticcheck -checks all $(PKGS)

misspell:
ifeq (,$(shell which misspell 2>/dev/null))
	@echo "===========> Installing misspell"
	$(GO) install github.com/client9/misspell/cmd/misspell
endif
	misspell \
		-locale GB \
		-error \
		*.md *.go

unconvert:
ifeq (,$(shell which unconvert 2>/dev/null))
	@echo "===========> Installing unconvert"
	$(GO) install github.com/mdempsky/unconvert@latest
endif
	unconvert -v $(PKGS)

ineffassign:
ifeq (,$(shell which ineffassign 2>/dev/null))
	@echo "===========> Installing ineffassign"
	$(GO) install github.com/gordonklaus/ineffassign@latest
endif
	find $(SRCDIRS) -name '*.go' | xargs ineffassign

pedantic: check errcheck

unparam:
ifeq (,$(shell which unparam 2>/dev/null))
	@echo "===========> Installing unparam"
	$(GO) install mvdan.cc/unparam@latest
endif
	unparam ./...

errcheck:
ifeq (,$(shell which errcheck 2>/dev/null))
	@echo "===========> Installing errcheck"
	$(GO) install github.com/kisielk/errcheck
endif
	errcheck $(PKGS)

gofmt:
	@echo Checking code is gofmted
	@test -z "$(shell gofmt -s -l -d -e $(SRCDIRS) | tee /dev/stderr)"
