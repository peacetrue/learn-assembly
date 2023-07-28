#构建系统级软件
SRC:=$(SRC)/x86

$(BUILD)/%.bin: $(SRC)/%.asm
	nasm $< -f bin -o $@

hello.case: $(BUILD)/hello.bin;
