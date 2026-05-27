SUBDIRS := $(patsubst %/,%,$(dir $(wildcard */Makefile)))

CLEAN_SUBDIRS := $(addprefix clean-,$(SUBDIRS))

.PHONY: all clean $(SUBDIRS) $(CLEAN_SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@echo "========================================"
	@echo " Building Sub-project: $@"
	@echo "========================================"
	$(MAKE) -C $@

clean: $(CLEAN_SUBDIRS)
	@echo "All projects cleaned."

$(CLEAN_SUBDIRS):
	$(MAKE) -C $(patsubst clean-%,%,$@) clean