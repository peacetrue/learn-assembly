#使用 qemu 调试程序
# https://wiki.qemu.org/Documentation
# https://www.qemu.org/docs/master/

# 创建一个磁盘镜像
$(BUILD)/%.qcow2: $(BUILD)
	qemu-img create -f qcow2 $@ 1K
	ls -lah $@

# 将程序代码拷贝到磁盘镜像中
qemu.copy.%: $(BUILD)/%.bin $(BUILD)/%.qcow2
	dd if=$< of=$(word 2,$^) bs=512 count=1 seek=0 conv=notrunc

# 运行 hello 案例
qemu.hello.case: qemu.run.hello;
# -boot c 从硬盘引导启动，-hda 指定硬盘位置
qemu.run.%: $(BUILD)/%.qcow2 qemu.copy.%
	qemu-system-x86_64 -boot c -hda $<

# 调试 hello 案例
qemu.hello.debug.case: qemu.debug.hello;
# 从命令行或者开发工具调试
qemu_debug_mode?=cli#cli|ide
# -s 选项允许 LLDB 连接到 QEMU，-S 选项则使得 QEMU 在启动时暂停，等待 LLDB 连接
ifeq ($(qemu_debug_mode),ide)
# TODO CLion 连接后，立即执行代码，失去调试机会，以下代码未能解决
./.lldbinit:
	echo "b 0x7c00" > $@
qemu.debug.%: $(BUILD)/%.qcow2 qemu.copy.% ./.lldbinit
	qemu-system-x86_64 -boot c -hda $< -s -S
else
$(BUILD)/%.qemu.source:
	echo "gdb-remote localhost:1234" > $@
	echo "b 0x7c00" >> $@
	echo "c" >> $@
	echo "b 0x7c89" >> $@
	echo "c" >> $@
qemu.debug.%: $(BUILD)/%.qcow2 $(BUILD)/%.qemu.source qemu.copy.%
	qemu-system-x86_64 -boot c -hda $< -s -S &
	lldb -s $(word 2,$^)
endif

# 清除所有案例
qemu.clean.case: qemu.clean.hello;
qemu.clean.%: clean/%.bin clean/%.qcow2 clean/%*qemu*;
