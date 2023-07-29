# 准备程序构建运行调试环境

# 查看软件的位置，//TODO Ubuntu 上如何安装 qemu
prepare.bins:=nasm bochs $(if $(is_mac),qemu-system-x86_64,)
prepare.locations:
	@for bin in $(prepare.bins) ; do \
		echo "$$bin: `which $$bin`"; \
	done

#软件所处目录
prepare.bin_dir:=$(if $(is_mac),/usr/local/bin,/usr/bin)

# mac 安装
ifdef is_mac
# 安装 brew
/usr/local/bin/brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 配置 brew
sudo_pwd?=123456
$(BUILD)/prepare.brew.cache: $(BUILD) /usr/local/bin/brew
	touch $@
	yes "$(sudo_pwd)" | sudo -S chown -R `whoami`:admin /usr/local/share

$(prepare.bin_dir)/%: $(BUILD)/prepare.brew.cache
	brew install $(subst qemu-system-x86_64,qemu,$*)
endif

# linux 安装
ifdef is_linux
$(prepare.bin_dir)/%:
	sudo apt install $(subst qemu-system-x86_64,qemu,$*) -y
endif

# 检查安装结果
prepare.check.%: $(prepare.bin_dir)/%
	$* -h

# 生成帮助文档
prepare.partials:=docs/antora/modules/ROOT/partials#文档位置
$(prepare.partials)/%.adoc:
	echo "= $*\n\n" > $@
	echo ".$* -h" >> $@
	echo "----" >> $@
	$* -h >> $@
	echo "----" >> $@

prepare.check.case: $(addprefix prepare.check.,$(prepare.bins));
prepare.adoc.case: $(prepare.partials)/nasm.adoc \
	$(prepare.partials)/bochs.adoc \
	$(prepare.partials)/qemu-system-x86_64.adoc \
	$(prepare.partials)/qemu-img.adoc \
	$(prepare.partials)/virtualbox.adoc \
	$(prepare.partials)/objcopy.adoc;

# brew install virtualbox --cask
