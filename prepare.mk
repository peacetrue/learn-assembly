# 准备程序构建运行调试环境

# 安装 brew
/usr/local/bin/brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 配置 brew
sudo_pwd?=123456
$(BUILD)/prepare.brew.config.cache: $(BUILD) /usr/local/bin/brew
	touch $@
	yes "$(sudo_pwd)" | sudo -S chown -R `whoami`:admin /usr/local/share

# mac 安装
ifdef is_mac
prepare.install.%: $(BUILD)/prepare.brew.config.cache
	brew install $*
endif

# linux 安装
ifdef is_linux
prepare.install.%:
	sudo apt install $* -y
endif

# 检查安装结果
prepare.check.%: prepare.install.%
	$* -h

# 生成帮助文档
prepare.partials:=docs/antora/modules/ROOT/partials#文档位置
$(prepare.partials)/%.adoc:
	echo "= $*\n\n" > $@
	echo ".$* -h" >> $@
	echo "----" >> $@
	$* -h >> $@
	echo "----" >> $@

prepare.check.case: prepare.check.nasm prepare.check.bochs;
prepare.adoc.case: $(prepare.partials)/nasm.adoc \
	$(prepare.partials)/bochs.adoc \
	$(prepare.partials)/qemu-system-x86_64.adoc \
	$(prepare.partials)/qemu-img.adoc \
	$(prepare.partials)/virtualbox.adoc \
	$(prepare.partials)/objcopy.adoc;

# brew install virtualbox --cask
