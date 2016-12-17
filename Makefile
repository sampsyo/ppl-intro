TARGETS := ppl
DEPS := style.mdk $(wildcard fig/*.pdf) $(wildcard fig/*.svg) \
	$(wildcard code/*.wppl)

DEST := dh:domains/adriansampson.net/doc
DEST_PATH := adriansampson.net/doc

include madoko.mk
