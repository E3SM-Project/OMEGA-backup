.SUFFIXES: .F90 .o
extension = .F90

SRC_DIR = .
OBJ_DIR = .
LIB_DIR = .
INC_DIR = .
FC = mpif90

# Dependency Generation
MAKE_DEP = $(SRC_DIR)/makedep.py
DEP_FILE = $(OBJ_DIR)/shared_deps.d

ifeq ($(FC),NONE)
  NOFC = TRUE
endif

MODULES = BGC_mod.F90 \
          BGC_parms.F90 \
          DMS_mod.F90 \
          DMS_parms.F90 \
          MACROS_mod.F90 \
          MACROS_parms.F90 \
          co2calc.F90

# Some compilers produce ALL_UPPER_CASE.mod files
ifeq ($(UCASE),TRUE)
  MODS_TMP = $(shell echo $(MODULES) | tr '[a-z]' '[A-Z]')
else
  MODS_TMP = $(MODULES)
endif
ifneq ($(OBJ_DIR),$(INC_DIR))
  INCS = $(addprefix $(INC_DIR)/,${MODS_TMP:.F90=.mod})
endif
MODS = $(addprefix $(OBJ_DIR)/,${MODS_TMP:.F90=.mod}) \
       $(INCS)
OBJS = $(addprefix $(OBJ_DIR)/,${MODULES:.F90=.o})

ifeq ($(USE_DEPS),TRUE)
  include $(DEP_FILE)
endif

### TARGETS ###

all: lib

# Create all object and module files
# Note that .mod files need to be copied to INC_DIR if OBJ_DIR != INC_DIR

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.F90
	$(FC) $(FCFLAGS) -c $< -o $@

$(INC_DIR)/%.mod: $(OBJ_DIR)/%.mod
ifneq ($(INC_DIR),$(OBJ_DIR))
	cp $< $@
endif

### Combine into library
$(LIB_DIR)/libBGC.a: $(OBJS)
	ar -ru $(LIB_DIR)/libBGC.a $(OBJS)

$(DEP_FILE): $(MAKE_DEP) $(SRC_DIR)/*.F90
	$(MAKE_DEP) $(DEP_FILE) $(OBJ_DIR) $(SRC_DIR)
	@echo "Generated dependencies!"

.PHONY: depends recurse check clean

# Shorthand for making dependency file
depends: $(DEP_FILE)

# Shorthand for making the library (and all .mod files)
lib: check depends
	$(MAKE) -e -f $(SRC_DIR)/Makefile $(LIB_DIR)/libBGC.a $(INCS) USE_DEPS=TRUE

# Make sure a Fortran compiler was specified (the Makefile for the stand-alone
# driver passes FC along with FCFLAGS, SRC_DIR, OBJ_DIR, LIB_DIR, and INC_DIR)
check:
	@$(if $(NOFC), echo "ERROR: you must specify FC (and it is recommended that \
     you specify FCFLAGS as"; echo "well)."; echo "NOTE: if you have checked  \
     out the stand-alone CVMix driver set then you should"; echo "run \"make  \
     lib\" from the src/ directory to use CVMix compile options."; exit 1)

# Remove library, object files, module files, and dependency file
clean:
	/bin/rm -f $(LIB_DIR)/libBGC.a $(OBJS) $(MODS) $(DEP_FILE) *.mod

