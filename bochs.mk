#使用 bochs 调试程序
# https://bochs.sourceforge.io/cgi-bin/topper.pl?name=New+Bochs+Documentation&url=https://bochs.sourceforge.io/doc/docbook/user/index.html

# 创建一个磁盘镜像
$(BUILD)/%.img: $(BUILD)
	yes | bximage -q -func=create -hd=16 -sectsize=512 -imgmode=flat $@

# 将程序代码拷贝到磁盘镜像中
bochs.copy.%: $(BUILD)/%.bin $(BUILD)/%.img
	dd if=$< of=$(word 2,$^) bs=512 count=1 seek=0 conv=notrunc

bochs_display_library?=$(if $(is_mac),sdl2,rfb)
# 配置 bochs 引导使用的磁盘
$(BUILD)/%.bochsrc: $(BUILD)/%.img
	echo "boot: disk" > $@
#	echo "ata0-master: type=disk, path=$<, mode=flat, cylinders=1, heads=1, spt=1" >> $@
	echo "ata0-master: type=disk, path=$<, mode=flat" >> $@
	echo "display_library: $(bochs_display_library)" >> $@
	echo "magic_break: enabled=1" >> $@

# 配置 bochs 执行的指令
## 默认 debug 模式
bochs_command_mode?=debug
## 执行模式
$(BUILD)/%.run.bochs.command: $(BUILD)
	echo "c" > $@
	echo "q" >> $@
## 调试模式
$(BUILD)/%.debug.bochs.command: $(BUILD)
	echo "b 0x7c00" > $@
	echo "c" >> $@

# 运行 hello 案例
bochs.hello.case: bochs.run.hello;
bochs.run.%: $(BUILD)/%.bochsrc $(BUILD)/%.$(bochs_command_mode).bochs.command bochs.copy.%
#	bochs -q -f $< -rc $(word 2,$^) -log $(BUILD)/$*.bochs.log
	bochs -q -f $< -rc $(word 2,$^)

# 清除所有案例
bochs.clean.case: bochs.clean.hello;
bochs.clean.%: clean/%.bin clean/%.img clean/%*bochs*;
