.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
ldc 0
iload0
ldc 0
istore 0
iload0
ldc 10
iload0
ldc1
iadd
istore 0
iload0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc \n
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload0
ldc 1
istore 0
iload0
ldc 0
iload0
ldc1
isub
istore 0
ldc 3
ldc 0
ldc 1
ldc 21
iadd
ldc 1
ldc 0
ldc 1
isub
ldc 2
ldc 1
ldc 3
idiv
ldc 2
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc \n
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

ldc 3
ldc 4
ldc 5
ldc 8
ineg
iadd
imul
isub
ldc 10
ldc 7
idiv
isub
ldc 4
ineg
ldc 3
idiv
iconst_1
iconst_0

ldc \n
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

ldc 3
ldc 0
ldc 1.100000
ldc 2.100000
fadd
ldc 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc \n
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

ldc 0
iload3
ldc 10
iload3
ldc 0
iload3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc \t
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload3
ldc1
isub
istore 3
iload3
ldc 0
ldc 3.140000
ldc 0.0
fstore 4
fload4
iload3
iadd
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc 6.600000
ldc 0.0
fstore 5
ldc If x == 
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

ldc 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

fload5
getstatic java/lang/System/out Ljava/io/PrintStream;
swap

ldc 1
ldc 0
istore 6
iload6
ldc 3
ldc \t
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc *
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload6
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc =
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload3
iload6
imul
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V

ldc \t
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

iload6
ldc1
iadd
istore 6
ldc \n
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println((Ljava/lang/String;)V

	return
.end method
