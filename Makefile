
RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix

NAME := project

ROM := $(NAME).gbc

SOURCES := source data
SOURCES := $(shell find $(SOURCES) -type d -print)

ASMFILES := $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.asm))

INCLUDES := $(foreach dir,$(SOURCES),-i$(dir)/)

OBJ := $(ASMFILES:.asm=.o)

.PHONY : all rebuild clean run

all: $(ROM)

clean:
	@echo rm $(OBJ) $(ROM) $(NAME).sym $(NAME).map
	@rm -f $(OBJ) $(ROM) $(NAME).sym $(NAME).map

%.o : %.asm
	@echo rgbasm $(INCLUDES) -E -o$@ $<
	@$(RGBASM) $(INCLUDES) -E -o$@ $<

$(ROM): $(OBJ)
	@echo linking $(ROM)
	@$(RGBLINK) -o $(ROM) -p 0xFF -m $(NAME).map -n $(NAME).sym $(OBJ)
	@echo rgbfix $(ROM)
	@$(RGBFIX) -C -p 0xFF -v $(ROM)
	@echo ROM fixed!

run: $(ROM) all
	sameboy $(ROM)
