# Fundamentals-of-compiling-grammar
# 语法分析器是基于bison构造的，大家可在linux环境下先下载安装好flex和bison
mylex.l文件就是词法分析程序，这里把第一次实验的.l文件做下修改就拿来用了。语法分析程序最核心的是myyacc.y文件，这里进行了语法制导的翻译和三地址代码的形成，大家可先行了解bison的使用方法。myyacc.h声明了可能需要用到的数据结构和方法，被myyacc.y调用。test1.in.txt就是测试文件。
在你的linux环境下创建这几个文件后，打开终端键入以下命令即可运行
```
flex -o mylex.yy.c mylex.l
bison -o myyacc.tab.h myyacc.y
gcc -o myyacc myyacc.tab.* mylex.yy.c -lfl
./myyacc<test1.in.txt
```
