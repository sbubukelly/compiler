/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    #define codegen(...) \
        do { \
            for (int i = 0; i < INDENT; i++) { \
                fprintf(fout, "\t"); \
            } \
            fprintf(fout, __VA_ARGS__); \
        } while (0)

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    
    /* Other global variables */
    FILE *fout = NULL;
    bool HAS_ERROR = false;
    int INDENT = 0;

    struct Node {
        char *name;
        char *type;
        int address;
        int lineno;
        char *elementType;
        struct Node *next;
    };
    struct Node *table[30] = { NULL };
    
    int Scope = 0;
    int AddressNum = 0;
    char *elementType = NULL;
    char typeChange;
    int assignAble = 1,assigned = 1,assignedID = 1,arr = 0,isFor = 0;
    int boolCount = 0,compareCount = 0,IfCount = 0,IfExitStackCount = 0;
    int IfStack[10],IfExitStack[10],IfStackCount = 0;
    struct Node *assignedNode = NULL;
    

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(char *name, char *type, char *elementType,int assign);
    static struct Node* lookup_symbol(char *name);
    static void dump_symbol();
    static void print(char *type);
    static void compare(char *type,char *op);
    static void store(struct Node *node);
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}
/* Token without return */
%token SEMICOLON
%token INT FLOAT BOOL STRING 
%token INC DEC GEQ LEQ EQL NEQ 
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token AND OR
%token PRINT 
%token IF ELSE FOR WHILE
%token TRUE FALSE

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <*s_val> ID

/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type TypeName INT FLOAT STRING BOOL
%type <s_val> Expr ExprAdd ExprAnd ExprCompare ExprMul ExprUnary Assignment
%type <s_val> PrintExpr Literal IncDecExpr Operand Primary Array ChangeType
// %type <s_val> While Block If If_block ElseIf_block Else_block For ForClause

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList     { dump_symbol(); }
;

StatementList
    : StatementList Statement
    | Statement
;

Statement
    : DeclarationStmt SEMICOLON     
    | Expr SEMICOLON     
    | IncDecExpr SEMICOLON     
    | PrintExpr SEMICOLON     
    | Assignment SEMICOLON    
    | Block  
    | While  
    | If  
    | For 
;

Assignment 
    : AssignedExpr {assignedID = 0;} '=' Expr   {   if(assigned == 0){
                                                        printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                        HAS_ERROR = true;
                                                        assigned = 1;
                                                    }
                                                    if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                        if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                            printf("error:%d: invalid operation: ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                            HAS_ERROR = true;
                                                        }
                                                    }
                                                    store(assignedNode);
                                                    assignedID = 1;$$ = $<s_val>1;
                                                }
    | AssignedExpr {assignedID = 0;} ADD_ASSIGN Expr    {   if(assigned == 0){
                                                                printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                                assigned = 1;
                                                                HAS_ERROR =true;
                                                            }
                                                            if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                                if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                                    printf("error:%d: invalid operation: ADD_ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                                    HAS_ERROR =true;
                                                                }
                                                            }
                                                            if(strcmp($<s_val>1,"int") == 0){
                                                                fprintf(fout,"iadd\n");
                                                            }
                                                            else if(strcmp($<s_val>1,"float") == 0){
                                                                fprintf(fout,"fadd\n");
                                                            }
                                                            store(assignedNode);
                                                            assignedID = 1;$$ = $<s_val>1;
                                                        }
    | AssignedExpr {assignedID = 0;} SUB_ASSIGN Expr    {   if(assigned == 0){
                                                                printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                                HAS_ERROR =true;
                                                                assigned = 1;
                                                            }
                                                            if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                                if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                                    printf("error:%d: invalid operation: SUB_ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                                    HAS_ERROR =true;
                                                                }
                                                            }
                                                            if(strcmp($<s_val>1,"int") == 0){
                                                                fprintf(fout,"isub\n");
                                                            }
                                                            else if(strcmp($<s_val>1,"float") == 0){
                                                                fprintf(fout,"fsub\n");
                                                            }
                                                            store(assignedNode); 
                                                            assignedID = 1;$$ = $<s_val>1;
                                                        }
    | AssignedExpr {assignedID = 0;} MUL_ASSIGN Expr    {   if(assigned == 0){
                                                                printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                                HAS_ERROR =true;
                                                                assigned = 1;
                                                            }
                                                            if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                                if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                                    printf("error:%d: invalid operation: MUL_ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                                    HAS_ERROR =true;
                                                                }
                                                            }
                                                            if(strcmp($<s_val>1,"int") == 0){
                                                                fprintf(fout,"imul\n");
                                                            }
                                                            else if(strcmp($<s_val>1,"float") == 0){
                                                                fprintf(fout,"fmul\n");
                                                            }
                                                            store(assignedNode);
                                                            assignedID =1;$$ = $<s_val>1;
                                                        }
    | AssignedExpr {assignedID = 0;} QUO_ASSIGN Expr    {   if(assigned == 0){
                                                                printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                                HAS_ERROR =true;
                                                                assigned = 1;
                                                            }
                                                            if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                                if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                                    printf("error:%d: invalid operation: QUO_ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                                }
                                                            }if(strcmp($<s_val>1,"int") == 0){
                                                                fprintf(fout,"idiv\n");
                                                            }
                                                            else if(strcmp($<s_val>1,"float") == 0){
                                                                fprintf(fout,"fdiv\n");
                                                            }
                                                            store(assignedNode);
                                                            assignedID = 1;$$ = $<s_val>1;
                                                        }
    | AssignedExpr {assignedID = 0;} REM_ASSIGN Expr    {   if(assigned == 0){
                                                                printf("error:%d: cannot assign to %s\n",yylineno,$<s_val>1);
                                                                HAS_ERROR =true;
                                                                assigned = 1;
                                                            }
                                                            if(strcmp($<s_val>1, $<s_val>4) != 0){
                                                                if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>4, "none") != 0){
                                                                    printf("error:%d: invalid operation: REM_ASSIGN (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                                                    HAS_ERROR =true;
                                                                }
                                                            }
                                                            if(strcmp($<s_val>1,"int") == 0){
                                                                fprintf(fout,"irem\n");
                                                            }
                                                            store(assignedNode); 
                                                            assignedID = 1;$$ = $<s_val>1;
                                                        }
;

AssignedExpr
    : Expr {if(assignAble == 0){assigned = 0;}}

DeclarationStmt
    : Type ID                   {insert_symbol($<s_val>2, $<s_val>1, "-",0);}
    | Type ID '=' Expr          {insert_symbol($<s_val>2, $<s_val>1, "-",1);}
    | Type ID '[' Expr ']'      {insert_symbol($<s_val>2,"array", $<s_val>1,0);assignAble = 1;}
    | Type ID '[' Expr ']' '=' Expr     {insert_symbol($<s_val>2,"array", $<s_val>1,1);assignAble = 1;}
;


Type
    : TypeName {$$=$1;}
;

TypeName
    : INT {$$="int";}
    | FLOAT {$$="float";}
    | STRING {$$="string";}
    | BOOL {$$="bool";}
;

IncDecExpr
    : Expr INC       {  char *tmp1;
                        char tmp2;
                        if(strcmp($<s_val>1,"int") == 0){tmp1 = "1";tmp2 = 'i';}
                        else if(strcmp($<s_val>1,"float") == 0){tmp1 = "1.0";tmp2 = 'f';}
                        fprintf(fout,"ldc %s\n",tmp1);
                        fprintf(fout,"%cadd\n",tmp2);
                        store(assignedNode);
                        assignAble = 0; $$=$1;}
    | Expr DEC       {  char *tmp1;
                        char tmp2;
                        if(strcmp($<s_val>1,"int") == 0){tmp1 = "1";tmp2 = 'i';}
                        else if(strcmp($<s_val>1,"float") == 0){tmp1 = "1.0";tmp2 = 'f';}
                        fprintf(fout,"ldc %s\n",tmp1);
                        fprintf(fout,"%csub\n",tmp2);
                        store(assignedNode);
                        assignAble = 0; $$=$1;}
;

PrintExpr
    : PRINT '(' Expr ')'    { print($<s_val>3); }
;

Expr
    : Expr OR ExprAnd    {  if(strcmp($<s_val>1,"bool") != 0){
                                printf("error:%d: invalid operation: (operator OR not defined on %s)\n",yylineno,$<s_val>1);
                                HAS_ERROR =true;
                            }
                            else if(strcmp($<s_val>3,"bool") != 0){
                                printf("error:%d: invalid operation: (operator OR not defined on %s)\n",yylineno,$<s_val>3);
                                HAS_ERROR =true;
                            }
                            fprintf(fout,"ior\n");
                            arr = 0;
                            assignAble = 0;$$ = "bool";}
    | ExprAnd {$$=$1;}
;

ExprAnd
    : ExprAnd AND ExprCompare   {   if(strcmp($<s_val>1,"bool") != 0){
                                        printf("error:%d: invalid operation: (operator AND not defined on %s)\n",yylineno,$<s_val>1);
                                        HAS_ERROR =true;
                                    }
                                    else if(strcmp($<s_val>3,"bool") != 0){
                                        printf("error:%d: invalid operation: (operator AND not defined on %s)\n",yylineno,$<s_val>3);
                                        HAS_ERROR =true;
                                    }
                                    fprintf(fout,"iand\n");
                                    arr = 0;assignAble = 0; $$ = "bool";}
    | ExprCompare {$$=$1;}
;

ExprCompare
    : ExprCompare '<' ExprAdd        {  compare($<s_val>1,"iflt");
                                        arr = 0;assignAble = 0; $$ = "bool"; }
    | ExprCompare '>' ExprAdd        {  compare($<s_val>1,"ifgt");
                                        arr = 0;assignAble = 0; $$ = "bool";   }
    | ExprCompare GEQ ExprAdd        {  compare($<s_val>1,"ifge");
                                        arr = 0;assignAble = 0; $$ = "bool";   }
    | ExprCompare LEQ ExprAdd        {  compare($<s_val>1,"ifle");
                                        arr = 0;assignAble = 0; $$ = "bool";   }
    | ExprCompare EQL ExprAdd        {  compare($<s_val>1,"ifeq");
                                        arr = 0;assignAble = 0; $$ = "bool";   }
    | ExprCompare NEQ ExprAdd        {  compare($<s_val>1,"ifne");
                                        arr = 0;assignAble = 0; $$ = "bool";   }
    | ExprAdd {$$=$1;}
;

ExprAdd
    : ExprAdd '+' ExprMul     { if(strcmp($<s_val>1, $<s_val>3) != 0){
                                    if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>3, "none") != 0){
                                        printf("error:%d: invalid operation: ADD (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                        HAS_ERROR =true;
                                    }
                                }
                                if(strcmp($<s_val>1,"int") == 0){
                                    fprintf(fout,"iadd\n");
                                }
                                else if(strcmp($<s_val>1,"float") == 0){
                                    fprintf(fout,"fadd\n");
                                }
                                arr = 0;assignAble = 0;$$ =  $<s_val>1;}
    | ExprAdd '-' ExprMul     { if(strcmp($<s_val>1, $<s_val>3) != 0){
                                    if(strcmp($<s_val>1, "none") != 0 && strcmp($<s_val>3, "none") != 0){
                                        printf("error:%d: invalid operation: SUB (mismatched types %s and %s)\n",yylineno,$<s_val>1,$<s_val>3);
                                        HAS_ERROR =true;
                                    }
                                }
                                if(strcmp($<s_val>1,"int") == 0){
                                    fprintf(fout,"isub\n");
                                }
                                else if(strcmp($<s_val>1,"float") == 0){
                                    fprintf(fout,"fsub\n");
                                }
                                arr = 0;assignAble = 0;$$ =  $<s_val>1;}   
    | ExprMul {$$=$1;}               
;

ExprMul
    : ExprMul '*' ExprUnary         {   if(strcmp($<s_val>1,"int") == 0){
                                            fprintf(fout,"imul\n");
                                        }
                                        else if(strcmp($<s_val>1,"float") == 0){
                                            fprintf(fout,"fmul\n");
                                        }
                                        arr = 0;assignAble = 0; $$ = $<s_val>1;}
    | ExprMul '/' ExprUnary         {   if(strcmp($<s_val>1,"int") == 0){
                                            fprintf(fout,"idiv\n");
                                        }
                                        else if(strcmp($<s_val>1,"float") == 0){
                                            fprintf(fout,"fdiv\n");
                                        }
                                        arr = 0;assignAble = 0; $$ = $<s_val>1;}
    | ExprMul '%' ExprUnary         {   if(strcmp($<s_val>1,"int") != 0){
                                            printf("error:%d: invalid operation: (operator REM not defined on %s)\n",yylineno,$<s_val>1);
                                            HAS_ERROR =true;
                                        }
                                        else if(strcmp($<s_val>3,"int") != 0){
                                            printf("error:%d: invalid operation: (operator REM not defined on %s)\n",yylineno,$<s_val>3);
                                            HAS_ERROR =true;
                                        }
                                        if(strcmp($<s_val>1,"int") == 0){
                                            fprintf(fout,"idiv\n");
                                        }
                                        arr = 0;assignAble = 0; $$ = $<s_val>1;}
    |ExprUnary {$$=$1;}
;

ExprUnary
    : '-' ExprUnary                 {   if(strcmp( $<s_val>2,"int") == 0){
                                            fprintf(fout,"ineg\n");
                                        }
                                        else if(strcmp( $<s_val>2,"float") == 0){
                                            fprintf(fout,"fneg\n");
                                        }  
                                        arr = 0;assignAble = 0; $$ = $<s_val>2; 
                                    }
    | '+' ExprUnary                   { arr = 0;assignAble = 0; $$ = $<s_val>2; }
    | '!'  ExprUnary         {      fprintf(fout,"iconst_1\n");
                                    fprintf(fout,"ixor\n");
                                    arr = 0;assignAble = 0; $$ = $<s_val>2; }
    | Primary {$$=$1;}

Primary
    : Operand { $$=$1;arr = 0;}
    | Array { $$=$1;}
    | ChangeType {$$=$1;arr = 0;}
;

Array
    : Operand '[' Expr ']'      {   if(assignedID == 0){
                                        fprintf(fout,"%caload\n",elementType[0]);
                                    }
                                    arr = 1;
                                    $$ = elementType; assignAble = 1; }
;

ChangeType
    : '(' Type ')' Expr    {   if(strcmp($<s_val>4, "int") == 0) typeChange = 'i';
                                else{typeChange = 'f';}
                                fprintf(fout,"%c2",typeChange);
                                if(strcmp($<s_val>2, "int") == 0) typeChange = 'i';
                                else{typeChange = 'f';}
                                fprintf(fout,"%c\n",typeChange);
                                $$ = $2;
                            }
;
Operand 
    : ID    {   struct Node *id = lookup_symbol($<s_val>1);
                if(id != NULL){
                    if(strcmp(id->type,"int") == 0){
                        fprintf(fout,"iload %d\n",id->address);
                    }
                    else if(strcmp(id->type,"float") == 0){
                       fprintf(fout,"fload %d\n",id->address);
                    }
                    else if(strcmp(id->type,"string") == 0){
                        fprintf(fout,"aload %d\n",id->address);
                    }
                    else if(strcmp(id->type,"bool") == 0){
                        fprintf(fout,"iload %d\n",id->address);
                    }
                    else if(strcmp(id->type,"array") == 0){
                        fprintf(fout,"aload %d\n",id->address);
                    }
                    $$ = id->type;
                    if (strcmp($$, "array") == 0)
                        elementType = id->elementType;
                    assignAble = 1;
                    if(assignedID == 1){
                        assignedNode = id;
                    }
                    
                }
                else{
                    $$ = "none";
                }
                
            }
    | Literal    { $$ = $<s_val>1; assignAble = 0;}
    | '(' Expr ')'    { $$ = $<s_val>2; }
;

Literal
    : INT_LIT                   { fprintf(fout,"ldc %d\n", $<i_val>1); $$ = "int"; }
    | FLOAT_LIT                 { fprintf(fout,"ldc %.6f\n", $<f_val>1); $$ = "float"; }
    | '\"' STRING_LIT '\"'      { fprintf(fout,"ldc \"%s\"\n", $<s_val>2); $$ = "string"; }
    | TRUE                      { fprintf(fout,"iconst_1\n"); $$ = "bool"; }
    | FALSE                     { fprintf(fout,"iconst_0\n"); $$ = "bool"; }
;

While
    : WHILE '(' Expr ')'    {   if(strcmp($<s_val>3, "bool") != 0){
                                    printf("error:%d: non-bool (type %s) used as for condition\n",yylineno + 1,$<s_val>3);
                                    HAS_ERROR =true;
                                }
                            } Block      
;

If
    : IF  '(' Expr ')' {    if(strcmp($<s_val>3, "bool") != 0){
                                    printf("error:%d: non-bool (type %s) used as for condition\n",yylineno + 1,$<s_val>3);
                                    HAS_ERROR =true;
                            }
                            fprintf(fout,"ifeq L_if_false_%d\n",IfCount);
                            IfStack[IfStackCount] = IfCount;
                            IfStackCount++;
                            IfExitStack[IfExitStackCount] = IfCount;
                            IfExitStackCount ++;
                            IfCount ++;
                        } If_block 
;

If_block
    : Block {   int curStack1 = 0;
                int curStack2 = 0;
                for(int i = 9;i >=0;i --){
                    if(IfStack[i] != -1){
                        curStack1 = i;
                        break;
                    }
                }
                for(int i = 9;i >=0;i --){
                    if(IfExitStack[i] != -1){
                        curStack2 = i;
                        break;
                    }
                }
                fprintf(fout,"goto L_if_exit_%d\n",IfExitStack[curStack2]);
                fprintf(fout,"L_if_false_%d:\n",IfStack[curStack1]);
                IfStack[curStack1] = -1;
                IfStackCount--;
                
            }   ElseBlock
    | Block {   int curStack1 = 0;
                int curStack2 = 0;
                for(int i = 9;i >=0;i --){
                    if(IfStack[i] != -1){
                        curStack1 = i;
                        break;
                    }
                }
                for(int i = 9;i >=0;i --){
                    if(IfExitStack[i] != -1){
                        curStack2 = i;
                        break;
                    }
                }
                fprintf(fout,"goto L_if_exit_%d\n",IfExitStack[curStack2]);
                fprintf(fout,"L_if_false_%d:\n",IfStack[curStack1]);
                IfStack[curStack1] = -1;
                IfStackCount--;
                fprintf(fout,"L_if_exit_%d:\n",IfExitStack[curStack2]);
                IfExitStack[curStack2] = -1;
                IfExitStackCount--;
                
            }  
ElseBlock
    : ELSE Block{    
                int curStack2 = 0;
                for(int i = 9;i >=0;i --){
                    if(IfExitStack[i] != -1){
                        curStack2 = i;
                        break;
                    }
                }
                fprintf(fout,"L_if_exit_%d:\n",IfExitStack[curStack2]);
                IfExitStack[curStack2] = -1;
                IfExitStackCount--;
            }
    | ELSE  IF  '(' Expr ')' {   if(strcmp($<s_val>4, "bool") != 0){
                                    printf("error:%d: non-bool (type %s) used as for condition\n",yylineno + 1,$<s_val>3);
                                    HAS_ERROR =true;
                                    }
                                fprintf(fout,"ifeq L_if_false_%d\n",IfCount);
                                IfStack[IfStackCount] = IfCount;
                                IfStackCount++;
                                IfCount ++;
                            } If_block 
;


For
    :FOR '(' Assignment SEMICOLON { fprintf(fout,"L_for_start:\n");
                                    } Expr {   fprintf(fout,"ifeq L_for_exit\n");
                                    } SEMICOLON ForIncDec

;

ForIncDec
    :ID INC ')' Block  {   struct Node *tmp = lookup_symbol($<s_val>1);
                        fprintf(fout,"iload %d\n",tmp->address);
                        fprintf(fout,"ldc %c\n",'1');
                        fprintf(fout,"%cadd\n",'i');
                        store(assignedNode);
                        fprintf(fout,"goto L_for_start\n");
                        fprintf(fout,"L_for_exit:\n");
                    }
    |ID DEC ')' Block  {   struct Node *tmp = lookup_symbol($<s_val>1);
                        fprintf(fout,"iload %d\n",tmp->address);
                        fprintf(fout,"ldc %c\n",'1');
                        fprintf(fout,"%csub\n",'i');
                        store(assignedNode);
                        fprintf(fout,"goto L_for_start\n");
                        fprintf(fout,"L_for_exit:\n");
                    }
    
;

Block
    : '{'{ create_symbol(); } StatementList '}'        { dump_symbol(); }
;


%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    for(int i = 0;i < 10;i ++){
        IfStack[i] = -1;
        IfExitStack[i] = -1;
    }
    /* Codegen output init */
    char *bytecode_filename = "hw3.j";
    fout = fopen(bytecode_filename, "w");
    codegen(".source hw3.j\n");
    codegen(".class public Main\n");
    codegen(".super java/lang/Object\n");
    codegen(".method public static main([Ljava/lang/String;)V\n");
    codegen(".limit stack 100\n");
    codegen(".limit locals 100\n");
    INDENT++;

    yyparse();

	printf("Total lines: %d\n", yylineno);

    /* Codegen end */
    codegen("return\n");
    INDENT--;
    codegen(".end method\n");
    fclose(fout);
    fclose(yyin);

    if (HAS_ERROR) {
        remove(bytecode_filename);
    }
    return 0;
}

static void print(char *type){
    if(arr == 1){
        fprintf(fout,"%caload\n",type[0]);
    }
    if(strcmp(type,"bool") != 0){
        fprintf(fout,"getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        fprintf(fout,"swap\n");
        if(strcmp(type,"int") == 0){
            fprintf(fout,"invokevirtual java/io/PrintStream/print(I)V\n");
        }
        else if(strcmp(type,"float") == 0){
            fprintf(fout,"invokevirtual java/io/PrintStream/print(F)V\n");
        }
        else if(strcmp(type,"string") == 0){
            fprintf(fout,"invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        }       
    }
    else if(strcmp(type,"bool") == 0){
        fprintf(fout,"ifne print_bool_%d\n",boolCount);
        fprintf(fout,"ldc \"false\"\n");
        fprintf(fout,"goto print_bool_%d\n",boolCount + 1);
        fprintf(fout,"print_bool_%d:\n",boolCount);
        fprintf(fout,"ldc \"true\"\n");
        fprintf(fout,"print_bool_%d:\n",boolCount +1);
        fprintf(fout,"getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        fprintf(fout,"swap\n");
        fprintf(fout,"invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        boolCount += 2; 
    }


    
    fprintf(fout,"\n");
}

static void compare(char *type,char *op){
    if(strcmp(type,"int") == 0){
        fprintf(fout,"isub\n");
        fprintf(fout,"%s L_cmp_%d\n",op,compareCount);
        fprintf(fout,"iconst_0\n");
        fprintf(fout,"goto L_cmp_%d\n",compareCount + 1);
        fprintf(fout,"L_cmp_%d:\n",compareCount);
        fprintf(fout,"iconst_1\n");
        fprintf(fout,"L_cmp_%d:\n",compareCount + 1);
    }
    else if(strcmp(type,"float") == 0){
        fprintf(fout,"fcmpl\n");
        fprintf(fout,"%s L_cmp_%d\n",op,compareCount);
        fprintf(fout,"iconst_0\n");
        fprintf(fout,"goto L_cmp_%d\n",compareCount + 1);
        fprintf(fout,"L_cmp_%d:\n",compareCount);
        fprintf(fout,"iconst_1\n");
        fprintf(fout,"L_cmp_%d:\n",compareCount + 1);
    }
    compareCount += 2;
}

static void store(struct Node* node){
    char *type = node->type;
    int addr = node->address;
    char *eleType = node -> elementType;
    if(strcmp(type,"int") == 0){
        fprintf(fout,"istore %d\n",addr);
    }
    else if(strcmp(type,"float") == 0){
        fprintf(fout,"fstore %d\n",addr);
    }
    else if(strcmp(type,"string") == 0){
        fprintf(fout,"astore %d\n",addr);
    }
    else if(strcmp(type,"bool") == 0){
        fprintf(fout,"istore %d\n",addr);
    }
    else if(strcmp(type,"array") == 0){
        fprintf(fout,"%castore\n",eleType[0]);
    }
}

static void create_symbol() {
    Scope++;
}

static void insert_symbol(char *name, char *type, char *elementType,int assign) {
    struct Node *current = table[Scope];
    int exist = false;
    while (current != NULL)
    {
        if (strcmp(current->name, name) == 0){
            exist = true;
            break;
        }
        current = current->next;
    }
    if(exist){
        printf("error:%d: %s redeclared in this block. previous declaration at line %d\n",yylineno,name,current->lineno);
        HAS_ERROR =true;
        return;
    }

    struct Node* new_node = (struct Node*) malloc(sizeof(struct Node));
    new_node->name = name;
    new_node->type = type;
    new_node->elementType = elementType;
    new_node->address = AddressNum++;
    new_node->lineno = yylineno;
    new_node->next = NULL;

    if(table[Scope] == NULL)
        table[Scope] = new_node;
    else {
        struct Node *current = table[Scope];
        while (current->next != NULL)
        {
            current = current->next;
        }
        current->next = new_node;
    }
    


    if(!assign){
        if(strcmp(type,"int") == 0){
            fprintf(fout,"ldc 0\n");
        }   
        else if(strcmp(type,"float") == 0){
            fprintf(fout,"ldc 0.0\n");
        }
        else if(strcmp(type,"string") == 0){
            fprintf(fout,"ldc \"\"\n");
        }
        else if(strcmp(type,"bool") == 0){
            fprintf(fout,"iconst_0\n");
        }
    }
    if(strcmp(type,"array") == 0){
         fprintf(fout,"newarray %s\n",elementType);
         if(!assign){
            fprintf(fout,"astore %d\n",new_node->address);
         }
         else{
            store(new_node); 
         }
    }
    else{
        store(new_node);
    }
    
}

static struct Node* lookup_symbol(char *name) {
    int cur = Scope;
    for(int i = cur;i >= 0;i --){
        struct Node *node = table[i];
        while(node != NULL){
            if (strcmp(node->name, name) == 0)
                return node;
            node = node->next;
        }
    }
    printf("error:%d: undefined: %s\n",yylineno,name);
    HAS_ERROR =true;
    return NULL;
}

static void dump_symbol() {
    int index = 0;
    struct Node *node = table[Scope];
    while (node != NULL) {
        struct Node *tmp = node;
        node = node->next;
        free(tmp);
    }
    table[Scope--] = NULL;
    
}
 