# 以下代码在 macOS 运行测试
# https://www.virtualbox.org/manual/
# https://www.virtualbox.org/manual/ch08.html 命令手册

# 查看虚拟机操作系统类型
$(BUILD)/ostypes.txt: $(BUILD)
	VBoxManage list ostypes > $@

# 以 .cache 结尾的文件为缓存文件，实际无用途，表示该目标已执行过，无需再执行
# 创建虚拟机，虚拟机实际创建在 % 目录下
$(BUILD)/%.vbox.cache: $(BUILD)
	touch $@
# 	|| true 防止重复执行时异常，以下同理
	VBoxManage createvm --name $* --basefolder=$(shell pwd)/$(BUILD) --ostype=Linux26_64 --register || true
	VBoxManage modifyvm $* --memory=10
	VBoxManage storagectl $* --name=$* --add=sata --bootable=on

# 创建虚拟硬盘，sizebyte 指定为 512 + 末尾的标志信息 = 1K
$(BUILD)/%.vhd: $(BUILD)
	VBoxManage createmedium disk --filename $(shell pwd)/$@ --sizebyte 512 --format VHD --variant Fixed || true
	ls -lh $@

# 配置虚拟硬盘
$(BUILD)/%.storageattach.cache: $(BUILD)/%.vbox.cache $(BUILD)/%.vhd
	touch $@
	VBoxManage storageattach $* --storagectl=$* --port=0 --device=0 --type=hdd --medium $(shell pwd)/$(word 2,$^) || true

# 将程序代码拷贝到虚拟硬盘中
vbox.copy.%: $(BUILD)/%.bin $(BUILD)/%.vhd
	dd if=$< of=$(word 2,$^) bs=512 count=1 seek=0 conv=notrunc;

# 运行虚拟机
vbox.run.%: $(BUILD)/%.storageattach.cache vbox.copy.%
	VBoxManage startvm $*

# 运行 hello 案例
vbox.hello.case: vbox.run.hello;

vbox/clean/%: clean/%.*.cache clean/%.bin
	VBoxManage unregistervm $* --delete
# 清除所有案例
vbox.clean.case: vbox/clean/hello;

