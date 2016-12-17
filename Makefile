TARGETS := ppl
DEPS := style.mdk $(wildcard fig/*.pdf) $(wildcard fig/*.svg) \
	$(wildcard code/*.wppl)

DEST := dh:domains/adriansampson.net
DEST_PATH := adriansampson.net

include madoko.mk
