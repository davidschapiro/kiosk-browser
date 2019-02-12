.PHONY: all build test install clean commit-release release deb repo
PACKAGE=kiosk-browser
SHELL=bash
VERSION := $(shell git rev-list HEAD --count --no-merges)
GIT_STATUS := $(shell git status --porcelain)


all: build

build:
	@echo No build required

commit-release:
ifneq ($(GIT_STATUS),)
	$(error Please commit all changes before releasing. $(shell git status 1>&2))
endif
	gbp dch --full --release --new-version=$(VERSION) --distribution stable --auto --git-author --commit
	git push

release: commit-release deb
	@latest_tag=$$(git describe --tags `git rev-list --tags --max-count=1`); \
	comparison="$$latest_tag..HEAD"; \
	if [ -z "$$latest_tag" ]; then comparison=""; fi; \
	changelog=$$(git log $$comparison --oneline --no-merges --reverse); \
	github-release schlomo/$(PACKAGE) v$(VERSION) "$$(git rev-parse --abbrev-ref HEAD)" "**Changelog**<br/>$$changelog" 'out/*.deb'; \
	git pull
	dput ppa:sschapiro/ubuntu/ppa/xenial out/$(PACKAGE)_*_source.changes

test:
	./runtests.sh

install:
	install -m 0644 00-disable-inputs.conf -D -t $(DESTDIR)/usr/share/X11/xorg.conf.d
	install -m 0755 kiosk-browser-control -D -t $(DESTDIR)/usr/bin
	install -m 0644 openbox-rc.xml -D -t $(DESTDIR)/usr/share/$(PACKAGE)
	install -m 0644 sudoers -D $(DESTDIR)/etc/sudoers.d/$(PACKAGE)
	install -m 0644 XOsview -D -t $(DESTDIR)/usr/lib/X11/app-defaults
	install -m 0755 xsession.sh -D -t $(DESTDIR)/usr/share/$(PACKAGE)

clean:
	rm -Rf debian/$(PACKAGE) debian/*debhelper* debian/*substvars debian/files out/*

deb: clean
ifneq ($(MAKECMDGOALS), release)
	$(eval DEBUILD_ARGS := -us -uc)
endif
	debuild $(DEBUILD_ARGS) -i -b --lintian-opts --profile debian
	debuild $(DEBUILD_ARGS) -i -S --lintian-opts --profile debian
	mkdir -p out
	mv ../$(PACKAGE)*.{xz,dsc,deb,build,changes,buildinfo} out/
	cd out ; apt-ftparchive packages . >Packages
	dpkg -I out/*.deb
	dpkg -c out/*.deb

repo:
	../putinrepo.sh out/*.deb

# vim: set ts=4 sw=4 tw=0 noet :
