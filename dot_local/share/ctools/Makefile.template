# =============================================================================
#* >> USER CONFIGURATION (MANDATORY)
# =============================================================================

NAME      ?= 
ifeq ($(NAME),)
    $(error NAME is empty: please define executable name)
endif

#? Directory (end with /)
SRC_DIR   = src/
OBJ_DIR   = build/
BIN_DIR   =

### UFILES_START ###
FILES     ?= 
### END ###
ifeq ($(FILES),)
    $(error FILES is empty: please define source files)
endif

# =============================================================================
#* >> USER CONFIGURATION (OPTIONAL)
# =============================================================================

AR        = ar rcs

CC        = cc
CFLAGS    = -Wall -Wextra -Werror

CXX       = c++
CXXFLAGS  = -Wall -Wextra -Werror -std=c++98

INCL_DIRS =
#? Directories & Libraries to link against
LIB_DIRS  =
LIB_FILES =

RM = rm -f
MD = mkdir -p

# =============================================================================
# >> COLORS
# =============================================================================

ESC = \033[
NC = $(ESC)0;39m

GRAY = $(ESC)0;90m
RED = $(ESC)0;91m
GREEN = $(ESC)0;92m
YELLOW = $(ESC)0;93m
BLUE = $(ESC)0;94m
MAGENTA = $(ESC)0;95m
CYAN = $(ESC)0;96m
UNDERLINE = $(ESC)4m

define clr_print
	@printf "$(1)$(2)$(NC)\n"
endef

# =============================================================================
# >> AUTOMATIC VARIABLES
# =============================================================================
C_FILES   := $(filter %.c,   $(FILES))
C_SRCS    := $(addprefix $(SRC_DIR), $(C_FILES))
C_OBJS    := $(patsubst $(SRC_DIR)%.c,   $(OBJ_DIR)%.o, $(C_SRCS))

CPP_FILES  := $(filter %.cpp, $(FILES))
CPP_SRCS   := $(addprefix $(SRC_DIR), $(CPP_FILES))
CPP_OBJS   := $(patsubst $(SRC_DIR)%.cpp, $(OBJ_DIR)%.o, $(CPP_SRCS))
COMPILE.cpp = 

SRCS      := $(C_SRCS) $(CPP_SRCS)
OBJS      := $(C_OBJS) $(CPP_OBJS)
DEPS      = $(OBJS:.o=.d)
O_DIRS     = $(sort $(dir $(OBJS)))

CPPFLAGS   = $(addprefix -I, $(INCL_DIRS))
LDFLAGS    = $(addprefix -L, $(LIB_DIRS))
LDLIBS     = $(addprefix -l, $(LIB_FILES))

#? Determin linker
ifeq ($(suffix $(NAME)), .a)
	LD = $(AR)
else ifneq ($(CPP_FILES),)
	LD = $(CXX)
else ifneq ($(C_FILES),)
	LD = $(CC)
else
	$(error Can't determine which linker to use. Please set LD manually.)
endif

OUT := $(if $(BIN_DIR),$(BIN_DIR),./)$(NAME)

export VERBOSE    := false
export P := @
ifeq ($(VERBOSE),true)
	P :=
endif

# =============================================================================
# >> RULES
# =============================================================================

.PHONY: all
all: $(OUT)

$(OUT): $(O_DIRS) $(OBJS)
	$(P)printf "$(GRAY)"
	$(LD) $(LDFLAGS) $(OBJS) -o $(OUT) $(LDLIBS)
	$(call clr_print,$(GREEN)$(UNDERLINE),$(NAME) compiled !)

$(O_DIRS):
	$(P)$(MD) $@

$(OBJ_DIR)%.o: $(SRC_DIR)%.c
	$(P)$(CC) $(CFLAGS) -MMD $(CPPFLAGS) -c $< -o $@
	$(call clr_print, $(YELLOW),Compiling C: $<)

$(OBJ_DIR)%.o: $(SRC_DIR)%.cpp
	$(P)$(CXX) $(CXXFLAGS) -MMD $(CPPFLAGS) -c $< -o $@
	$(call clr_print, $(YELLOW),Compiling C++: $<)

-include $(DEPS)

.PHONY: clean
clean:
	$(P)$(RM) $(OBJS) $(DEPS)
	$(P)$(RM) -r $(OBJ_DIR)
	$(call clr_print,$(BLUE),$(NAME) object files cleaned!)

.PHONY: fclean
fclean: clean
	$(P)$(RM) $(OUT)
	$(call clr_print,$(CYAN),executables files cleaned!)

.PHONY: re
re: fclean all

.PHONY: run
run: $(OUT)
	$(OUT)
