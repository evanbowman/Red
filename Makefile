
RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix

NAME := Red

ROM := $(NAME).gbc

SOURCES := source data
SOURCES := $(shell find $(SOURCES) -type d -print)

ASMFILES := $(foreach dir,$(SOURCES),$(wildcard $(dir)/main.asm))
ASMDEPS := $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.asm))

INCLUDES := $(foreach dir,$(SOURCES),-i$(dir)/)

OBJ := $(ASMFILES:.asm=.o)

.PHONY : all rebuild clean run

all: $(ROM)

clean:
	@echo rm $(OBJ) $(ROM) $(NAME).sym $(NAME).map
	@rm -f $(OBJ) $(ROM) $(NAME).sym $(NAME).map

# Yeah, I know, this is kind of lazy. The main asm file simply includes the
# other source files. I have reasons for doing this.
source/main.o : $(ASMDEPS)
	@echo rgbasm -Wall -Wextra $(INCLUDES) -E -osource/main.o source/main.asm
	@$(RGBASM) -Wall -Wextra $(INCLUDES) -E -osource/main.o source/main.asm


$(ROM): $(OBJ)
	@echo linking $(ROM)
	@$(RGBLINK) -o $(ROM) -p 0xFF -m $(NAME).map -n $(NAME).sym $(OBJ)
	@echo rgbfix $(ROM)
	@$(RGBFIX) -p 0xFF --mbc-type 0x1B --ram-size 4 -C -t RED -v $(ROM)
	@echo ROM fixed!

run: $(ROM) all
	sameboy $(ROM)


bgb: $(ROM) all
	wine ~/Desktop/bgb.exe $(ROM)
