.PHONY: serve build check clean

HUGO_BASE_URL ?= https://danialjfz.github.io/myblog/

serve:
	hugo server --buildDrafts --bind 127.0.0.1 --baseURL http://localhost:1313/myblog/

build:
	rm -rf public/
	hugo --gc --minify --baseURL $(HUGO_BASE_URL)

check: build
	@echo "Build complete. Inspect public/ manually or run htmltest if installed."

clean:
	rm -rf public/ resources/_gen/ .hugo_build.lock
