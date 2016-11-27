HTML_DIR := html
PDF_DIR := pdf
MADOKO := madoko

MARKDOWN := $(TARGET).md
PDF := $(PDF_DIR)/$(TARGET).pdf
HTML := $(HTML_DIR)/$(TARGET).html

# Shortcuts.
.PHONY: pdf html
pdf: $(PDF)
html: $(HTML)

# Build PDF via LaTeX.
$(PDF): $(MARKDOWN) $(DEPS)
	$(MADOKO) --odir=$(PDF_DIR) --pdf $<

# Build Web page.
$(HTML): $(MARKDOWN) $(DEPS)
	$(MADOKO) --odir=$(HTML_DIR) $<

.PHONY: clean
clean:
	rm -rf $(PDF_DIR) $(HTML_DIR)

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
	liveserve $(LIVESERVE_ARGS) -x 'make html' $(HTML_DIR)

watch: watch-pdf
