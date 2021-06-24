.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
ldc 400
istore 0
ldc 700
istore 1
iload 0
ldc 400
isub
ifeq L_cmp_0
iconst_0
goto L_cmp_1
L_cmp_0:
iconst_1
L_cmp_1:
ifeq L_if_false_0
ldc "OuO\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V

iload 1
ldc 600
isub
ifle L_cmp_2
iconst_0
goto L_cmp_3
L_cmp_2:
iconst_1
L_cmp_3:
ifeq L_if_false_1
ldc "No\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V

L_if_false_1:
iload 1
ldc 700
isub
ifeq L_cmp_4
iconst_0
goto L_cmp_5
L_cmp_4:
iconst_1
L_cmp_5:
ifeq L_if_false_2
ldc "Value of v1 is 400 and v2 is 700"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V

L_if_false_2:
ifeq L_if_false_3
ldc "QuQ\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V

L_if_false_3:
L_if_false_0:
L_if_false_-1:
L_if_false_-1:
	return
.end method
