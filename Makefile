TARGETS := ppl
DEPS := style.mdk $(wildcard fig/*.pdf) $(wildcard fig/*.svg) \
	$(wildcard code/*.wppl)

DEST := dh:domains/adriansampson.net/ppl
DEST_PATH := adriansampson.net/ppl

include madoko.mk
