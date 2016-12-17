TARGETS := ppl
DEPS := style.mdk $(wildcard fig/*.pdf) $(wildcard fig/*.svg) \
	$(wildcard code/*.wppl)
include madoko.mk
