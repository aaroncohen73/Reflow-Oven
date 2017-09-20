MCU := atmega328
PROGRAMMER := arduino
PROGRAMMER_PORT := /dev/ttyUSB0

CC := avr-gcc
OBJCOPY := avr-objcopy
AVRDUDE := avrdude
CFLAGS := -O0 -fpack-struct -Wall -Wextra -Wstrict-prototypes -std=gnu99

OUT := oven
OBJ := spi.o
MAIN := oven.c

.PHONY: clean fuses download

all: $(OUT).bin download

$(OUT).bin: $(OBJ)
	@$(CC) -mmcu=$(MCU) $(CFLAGS) $(MAIN) $(OBJ) -o $(OUT).elf
	@$(OBJCOPY) -O binary $(OUT).elf $(OUT).bin

%.o: %.c %.h
	@$(CC) -mmcu=$(MCU) $(CFLAGS) -c $< -o $@

clean:
	@rm -f $(OBJ) $(OUT).elf $(OUT).bin
