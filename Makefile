TARGET := ppl
DEPS := style.mdk $(wildcard fig/*.pdf) $(wildcard fig/*.svg)
include madoko.mk
