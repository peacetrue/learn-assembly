.SECONDARY:#保留中间过程文件
include os.mk
include build.common.mk
include prepare.mk
include build.nasm.mk
include vbox.mk
include bochs.mk
include qemu.mk

