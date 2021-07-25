TARGET = gw_nim_app
OPT ?= -g -Og
NIMOPT ?= --debugger:native -d:danger

NIM_SOURCES = \
	src/test_app.nim \
	src/gnw.nim

NIM_TARGET = src/test_app.nim

C_SOURCES = \
	Core/Src/system_stm32h7xx.c \
	Core/Src/stm32h7xx_it.c \
	Core/Src/gw_buttons.c \
	Core/Src/stm32h7xx_hal_msp.c \
	Core/Src/gw_flash.c \
	Core/Src/gw_lcd.c \
	Core/Src/gw_alloc.c \
	Core/Src/main.c \
	Core/Src/bq24072.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_sai_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_spi.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_adc_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_hsem.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rtc.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_wwdg.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_tim.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dac.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_ltdc_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2c.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rtc_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_flash_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_ospi.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_adc.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dma_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_cortex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_ltdc.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2c_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_flash.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_gpio.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dma.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_exti.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_mdma.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_spi_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dac_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_tim_ex.c \
	Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_sai.c \

C_INCLUDES +=  \
	-ICore/Inc \
	-IDrivers/STM32H7xx_HAL_Driver/Inc \
	-IDrivers/STM32H7xx_HAL_Driver/Inc/Legacy \
	-IDrivers/CMSIS/Device/ST/STM32H7xx/Include \
	-IDrivers/CMSIS/Include \

ASM_SOURCES =  \
	Drivers/CMSIS/Device/ST/STM32H7xx/Source/Templates/gcc/startup_stm32h7b0xx.s \
	Core/Src/memcpy-armv7m.s \

# setup arm toolchain
PREFIX = arm-none-eabi-
CC   = $(PREFIX)gcc
AS   = $(PREFIX)gcc -x assembler-with-cpp
CP   = $(PREFIX)objcopy
SZ   = $(PREFIX)size
GDB  = gdb #$(PREFIX)gdb
DUMP = $(PREFIX)objdump
HEX   = $(CP) -O ihex
BIN   = $(CP) -O binary -S

# set flags to target microcontroller
CPU = -mcpu=cortex-m7 -mtune=cortex-m7
FPU = -mfpu=fpv5-d16
FLOAT-ABI = -mfloat-abi=hard
MCU = $(CPU) -mthumb -mno-unaligned-access $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS +=

# C defines
C_DEFS +=  \
	-DUSE_HAL_DRIVER \
	-DSTM32H7B0xx \
	-DVECT_TAB_ITCM \
	-DIS_LITTLE_ENDIAN \
	-DDEBUG_RG_ALLOC \

# compile gcc flags
ASFLAGS += $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS += $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

# detect stack overflow (adjust according to _Min_Stack_Size in STM32H7B0VBTx_FLASH.ld)
CFLAGS += -fstack-usage -Wstack-usage=20480

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# Set external flash size (default to 1MB)
EXTFLASH_SIZE ?= 1048576
LDFLAGS += -Wl,--defsym=__EXTFLASH_TOTAL_LENGTH__=$(EXTFLASH_SIZE)

# ld script setups memory layout and elf sections
LDSCRIPT = STM32H7B0VBTx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys
LDFLAGS += $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(TARGET).map,--cref -Wl,--gc-sections

all: $(TARGET).elf $(TARGET)_extflash.bin $(TARGET)_intflash.bin

OBJECTS=$(patsubst %.c,%.o,$(C_SOURCES)) $(patsubst %.s,%.o,$(ASM_SOURCES))

$(TARGET).elf: $(OBJECTS) $(NIM_SOURCES)
	@mkdir -p $(CURDIR)/nimcache
	nim c $(NIMOPT) --nimcache=$(CURDIR)/nimcache $(NIM_TARGET)
	$(CC) $(OBJECTS) $(CURDIR)/nimcache/*.o $(LDFLAGS) -o $@
	$(SZ) $@

%.o: %.c 
	$(CC) -c $(CFLAGS) $< -o $@

%.o: %.s 
	$(AS) -c $(CFLAGS) $< -o $@

# sections that are copied to external flash
$(TARGET)_extflash.bin: $(TARGET).elf 
	$(BIN) -j ._itcram_hot -j ._ram_exec -j ._extflash $< $(TARGET)_extflash.bin

# sections that are copied to internal flash
$(TARGET)_intflash.bin: $(TARGET).elf 
	$(BIN) -j .isr_vector -j .text -j .rodata -j .ARM.extab -j .preinit_array -j .init_array -j .fini_array -j .data $< $(TARGET)_intflash.bin

OPENOCD ?= openocd
ADAPTER ?= stlink
FLSHLD_DIR ?= ../game-and-watch-flashloader
FLASHLOADER ?= $(FLSHLD_DIR)/flash_multi.sh

# Programs the internal and external flash using OpenOCD 
flash_intflash: $(TARGET)_intflash.bin
	$(OPENOCD) -f $(FLSHLD_DIR)/interface_$(ADAPTER).cfg -c "program $< 0x08000000 verify reset exit"
.PHONY: flash_intflash

flash_extflash: $(TARGET)_extflash.bin
	$(FLASHLOADER) $<
.PHONY: flash_extflash

# Programs both the external and internal flash.
flash: flash_extflash flash_intflash
.PHONY: flash

# run debugger
gdb: $(TARGET).elf
	$(GDB) $< -ex "target extended-remote :3333"
.PHONY: gdb

# run st-link side of debugger
debug: 
	st-util -p 3333
.PHONY: debug

clean:
	rm -rf nimcache
	rm -f $(TARGET).{map,elf} $(TARGET)_{ext,int}flash.bin
	find . -name '*.o' -or -name '*.d' -or -name '*.su' | xargs rm
#-include $(wildcard $(BUILD_DIR)/*.d)
