# rules for kde stuff

# meta object creation
MOCS := $(filter-out $(NOT_MOCS), $(notdir $(wildcard $(X_MODULE)/*.hh)))
SRCS := $(SRCS) $(addsuffix .moc.cc, $(basename $(MOCS)))

$($(X_MODULE)_OUTPUT)/%.moc.cc: $(X_MODULE)/%.hh
	@echo '  MOC       $@'
	$(Q)moc $< > $@

