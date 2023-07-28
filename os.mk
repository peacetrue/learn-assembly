# 本文件用于设置与操作系统相关的变量
os:=$(shell uname)#操作系统名称
override os_linux:=Linux#常量
override os_mac:=Darwin#常量
os_name:=$(if $(filter $(os),$(os_linux)),linux,macosx)
override is_linux:=$(filter $(os),$(os_linux))
override is_mac:=$(filter $(os),$(os_mac))

os.vars:
	@echo "os: '$(os)'"
	@echo "os_name: '$(os_name)'"
	@echo "is_linux: '$(is_linux)'"
	@echo "is_mac: '$(is_mac)'"
