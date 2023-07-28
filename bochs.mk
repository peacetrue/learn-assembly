#使用 bochs 调试程序
# src/bochsrc bochs 配置详解

# 创建一个磁盘镜像
$(BUILD)/%.img:
	yes | bximage -q -func=create -hd=16 -sectsize=512 -imgmode=flat $@;

# 将程序代码拷贝到磁盘镜像中
copy.bin.img.%: $(BUILD)/%.bin $(BUILD)/%.img
	dd if=$< of=$(word 2,$^) bs=512 count=1 seek=0 conv=notrunc;

# 配置 bochs 引导使用的磁盘
$(BUILD)/%.bochsrc: $(BUILD)/%.img
	echo "boot: disk" > $@
#	echo "ata0-master: type=disk, path=$<, mode=flat, cylinders=1, heads=1, spt=1" >> $@
	echo "ata0-master: type=disk, path=$<, mode=flat" >> $@
	echo "display_library: sdl2" >> $@

# 配置 bochs 自动执行的指令
$(BUILD)/%.bochi:
	echo "b 0x7c00" > $@
	echo "c" >> $@
	echo "n" >> $@
	echo "c" >> $@

# 运行 bochs 调试
bochs.run.%: $(BUILD)/%.bochsrc $(BUILD)/%.bochi copy.bin.img.%
	bochs -q -f $< -rc $(word 2,$^) -log $(BUILD)/$*.bochs.log

# clean/hello.bochsrc
bochs.hello.case: bochs.run.hello;
