# 准备程序构建运行调试环境

prepare.partials:=docs/antora/modules/ROOT/partials#文档位置

# brew install virtualbox --cask

# 安装 brew
/usr/local/bin/brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ifdef is_mac
prepare.install.%: /usr/local/bin/brew
	brew install $*
endif

ifdef is_linux
prepare.install.%:
	sudo apt install $* -y
endif

# 生成帮助文档
$(prepare.partials)/%.adoc: prepare.install.%
	echo "= $*\n\n" > $@
	echo ".$* -h" >> $@
	echo "----" >> $@
	$* -h >> $@
	echo "----" >> $@

prepare.install.case: prepare.install.nasm prepare.install.bochs;
prepare.case: $(prepare.partials)/nasm.adoc $(prepare.partials)/bochs.adoc $(prepare.partials)/VBoxManage.adoc $(prepare.partials)/objcopy.adoc;
#
