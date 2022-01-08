include build/$(X_SYSTEM).make

X_SRCS = $(filter-out $(NOT_SRCS), $(sort $(notdir $(wildcard $(X_MODULE)/*.cc $(X_MODULE)/*.c $(X_MODULE)/*.m $(X_MODULE)/*.mm)))) $(SRCS)
$(X_MODULE)_OBJS := $(addsuffix $(X_OBJEXT),$(addprefix $($(X_MODULE)_OUTPUT)/,$(basename $(X_SRCS)))) $(DEPS)
$(X_MODULE)_BINARY := $(addsuffix $(BINARY_EXT),$(addprefix $($(X_MODULE)_OUTPUT)/,$(BINARY)))


X_DEP_FILES := $(addsuffix .d,$(addprefix $($(X_MODULE)_OUTPUT)/,$(basename $(X_SRCS)))) # $(DEPS)


# include build/$(X_ARCH).make
# include build/$(X_CC).make

# dependencies

ifneq ($(X_DEP_FILES),)
  -include $(X_DEP_FILES)
endif

# rules

Q = @

ifneq ($(X_BUILD_IMPLICIT),0)
ifneq ($(X_NO_INSTALL),1)
  all:: $($(X_MODULE)_BINARY)
  install:: $($(X_MODULE)_BINARY)
	$(Q)for x in $^; do \
	  case $$x in \
		*$(X_DYNEXT) ) echo INSTALL DYNLIB $$x; mkdir -p $(DESTDIR)$(libdir)/; install $$x $(DESTDIR)$(libdir)/ ;; \
		*$(X_LIBEXT) ) ;; \
		*$(X_EXEEXT) ) echo INSTALL EXEC   $$x; mkdir -p $(DESTDIR)$(bindir)/; install $$x $(DESTDIR)$(bindir)/ ;; \
	  esac ;\
	done
endif
endif

$(X_MODULE): $($(X_MODULE)_BINARY)

$($(X_MODULE)_OUTPUT)/%.o: $(X_MODULE)/%.c
	@echo '  C         $@'
	$(Q)$(COMPILE.c) $($(dir $@)CFLAGS) $($(<)/CFLAGS) -MMD -MP -MF '$(patsubst %.o,%.d,$@)' -o '$@' '$<'

$($(X_MODULE)_OUTPUT)/%.o: $(X_MODULE)/%.m
	@echo '  ObjC      $@'
	$(Q)$(COMPILE.c) $($(dir $@)CFLAGS) $($(<)/CFLAGS) -MMD -MP -MF '$(patsubst %.o,%.d,$@)' -o '$@' '$<'

$($(X_MODULE)_OUTPUT)/%.o: $($(X_MODULE)_OUTPUT)/%.cc
	@echo '  C++       $@'
	$(Q)$(COMPILE.cc) $($(dir $@)CXXFLAGS) $($(<)/CXXFLAGS) -MMD -MP -MF '$(patsubst %.o,%.d,$@)' -o '$@' '$<'

$($(X_MODULE)_OUTPUT)/%.o: $(X_MODULE)/%.cc
	@echo '  C++       $@'
	$(Q)$(COMPILE.cc) $($(dir $@)CXXFLAGS) $($(<)/CXXFLAGS) -MMD -MP -MF '$(patsubst %.o,%.d,$@)' -o '$@' '$<'

$($(X_MODULE)_OUTPUT)/%.o: $(X_MODULE)/%.mm
	@echo '  ObjC++    $@'
	$(Q)$(COMPILE.cc) $($(dir $@)CXXFLAGS) $($(<)/CXXFLAGS) -MMD -MP -MF '$(patsubst %.o,%.d,$@)' -o '$@' '$<'

# only implicit rules if one binary per module ...
ifeq ($(words $(BINARY)), 1)

$($(X_MODULE)_OUTPUT)/$(BINARY)$(X_LIBEXT): $($(X_MODULE)_OBJS)
	@echo '  LINK LIB  $@'
	$(Q)$(LD) -r -o '$@' $^
#	# no AR anymore due to static initilizers
#	$(Q)$(AR) r '$@' $^ 2> /dev/null
#	$(Q)$(RANLIB) '$@'

$($(X_MODULE)_OUTPUT)/$(BINARY)$(X_DYNEXT): $($(X_MODULE)_OBJS)
	@echo '  LINK DYN  $@'
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $($(dir $@)CXXFLAGS) $(TARGET_ARCH) $(X_DYNFLAGS) -o '$@' $^ $(LDFLAGS) $($(dir $@)LDFLAGS)

$($(X_MODULE)_OUTPUT)/$(BINARY)$(X_EXEEXT): $($(X_MODULE)_OBJS)
	@echo '  LINK EXEC $@'
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $($(dir $@)CXXFLAGS) $(TARGET_ARCH) $(X_EXEFLAGS) -o '$@' $^ $(LDFLAGS) $($(dir $@)LDFLAGS)

endif

$($(X_MODULE)_OUTPUT)/%$(X_EXEEXT): $($(X_MODULE)_OUTPUT)/%.o $(DEPS)
	@echo '  LINK EXEC $@'
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $($(dir $@)CXXFLAGS) $(TARGET_ARCH) $(X_EXEFLAGS) -o '$@' $^ $(LDFLAGS) $($(dir $@)LDFLAGS)
