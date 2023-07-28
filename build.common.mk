# 构建通用文件，声明构建目录的创建和清除
override src:=src#源始文件目录，作为常量使用，请勿改变该值
SRC:=$(src)#作为变量使用

override build:=build#目标文件目录，作为常量使用，请勿改变该值
BUILD:=$(build)#作为变量使用

mkdir/%:; mkdir -p $*
mkdir: mkdir/$(BUILD);
#所有不带食谱的规则，需要以分号结尾。去掉 $(BUILD)/% 后的分号，执行 make common.case，出现以下错误
# make: *** No rule to make target `build/test', needed by `common.case'.  Stop.
$(BUILD): mkdir;
#$(BUILD)/%: mkdir/$(BUILD)/%; #此目标导致 $(BUILD)/%.txt 类写法全部失效

#如果是删除 build 目录，使用 -f 强制删除
rm/%:; rm -r$(if $(filter $(build)%,$*),f,) $*
rm: rm/$(BUILD);
clean: rm;
clean/%: rm/$(BUILD)/%;

#测试上述规则
common.case: $(BUILD) $(BUILD)/test clean/test clean rm/empty
