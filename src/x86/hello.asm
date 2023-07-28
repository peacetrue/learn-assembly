; 系统级 Hello World 程序，在屏幕上打印 Hello World！ 字符
; 直接打印 Hello World
mov ax, 0xb800; 文本模式下的显存地址
mov ds, ax; ds 指定数据段基址，以下地址皆基于 ds 偏移
mov byte [0],'H'
mov byte [1],0x07
mov byte [2],'e'
mov byte [3],0x07
mov byte [4],'l'
mov byte [5],0x07
mov byte [6],'l'
mov byte [7],0x07
mov byte [8],'o'
mov byte [9],0x07
mov byte [10],' '
mov byte [11],0x07
mov byte [12],'W'
mov byte [13],0x07
mov byte [14],'o'
mov byte [15],0x07
mov byte [16],'r'
mov byte [17],0x07
mov byte [18],'d'
mov byte [19],0x07
mov byte [20],'!'
mov byte [21],0x07

; 使用循环打印 Hello World
;源地址
mov ax,0x07c0
mov ds,ax
mov si,string
;目的地址
mov ax,0xb800
mov es,ax
mov di,22; 22 是之前已经打印到的位置
cld;清零方向标志，默认正向即从低地址到高地址
mov cx,(string.end-string)/2; Hello Word 的长度
rep movsw;重复执行指令 cx 次，每次传输一个字
;rep movsw word ptr es:[di], word ptr ds:[si] ; f3a5

jmp $ ;$ 代表当前汇编语句的地址

string:
    db 'H',0x07,'e',0x07,'l',0x07,'l',0x07,'o',0x07,' ',0x07,'W',0x07,'o',0x07,'r',0x07,'l',0x07,'d',0x07,'!',0x07
string.end:

times 512 - 2 - ($ - $$) db 0 ;$$ 代表当前代码段（section）的起始地址即 0
db 0x55,0xaa; 声明字节(Declare Byte)。主引导扇区标志，必须在第一扇区的末尾
