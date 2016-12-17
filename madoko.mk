MADOKO := madoko
BUILD_DIR := build

MARKDOWN := $(TARGETS:%=%.md)
PDF := $(TARGETS:%=$(BUILD_DIR)/%.pdf)
HTML := $(TARGETS:%=$(BUILD_DIR)/%.html)

# Shortcuts.
.PHONY: pdf html
pdf: $(PDF)
html: $(HTML)

# Build PDF via LaTeX.
$(BUILD_DIR)/%.pdf: %.md $(DEPS)
	$(MADOKO) --odir=$(BUILD_DIR) --pdf $<

# Build Web page.
$(BUILD_DIR)/%.html: %.md $(DEPS)
	$(MADOKO) --odir=$(BUILD_DIR) $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: deploy
DEST_URL := http://$(DEST_PATH)/$(notdir $(PDF))
deploy: $(PDF)
	scp $< $(DEST)
	@echo $(DEST_URL)


# View products.

OS=$(shell uname -s)
ifeq ($(OS),Darwin)
OPEN ?= open
else
OPEN ?= xdg-open
endif

.PHONY: view view-html
view: $(PDF)
	$(OPEN) $(PDF)
view-html: $(HTML)
	$(OPEN) $(HTML)


# Auto-build based on `livereload`.

.PHONY: watch watch-pdf watch-html

LIVESERVE_ARGS := -w $(MARKDOWN) $(DEPS:%=-w %)

watch-pdf:
	liveserve $(LIVESERVE_ARGS) -x 'make pdf' -S

watch-html:
	liveserve $(LIVESERVE_ARGS) -x 'make html' $(BUILD_DIR)

watch: watch-pdf
