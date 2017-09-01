%{
  #include "constantes.h"
%}
digito [0-9]
letra [A-Za-z]
operador [-+*~/<:;{}()=.]|"<-"|"<="
blanco [ \n\f\r\t\v]
keyword "class"|"if"|"then"|"else"|"while"|"do"|"od"|"case"|"of"|"new"|"isvoid"|"not"|"true"|"false"
%x comment
%%
{digito}+                     {ECHO;fwrite("\t1\n",1,3,yyout);}
{keyword}                     {ECHO;fwrite("\t4\n",1,3,yyout);}
({letra}|{digito}|"_")+       {ECHO;fwrite("\t2\n",1,3,yyout);}
\"(\\.|[^\\"\0])*\"           {ECHO;fwrite("\t3\n",1,3,yyout);}
{blanco}+                     {ECHO;fwrite("\t5\n",1,3,yyout);}
"//"[^\n]*\n                  {ECHO;fwrite("\t6\n",1,3,yyout);}
"/*"                          {ECHO;BEGIN(comment);}
<comment>[^*\n]*              ECHO;
<comment>"*"+[^*/\n]*         ECHO;
<comment>"*"+"/"              {ECHO;fwrite("\t6\n",1,3,yyout);BEGIN(INITIAL);}
{operador}                    {ECHO;fwrite("\t7\n",1,3,yyout);}
.                             {ECHO;fwrite("\tNo se reconoce\n",1,16,yyout);}
%%
int
yywrap (void) {
  return 1;
}

int
main (int argc, char* argv[]) {
  yyin = fopen (argv[1],"r");
  yyout = fopen (argv[2],"w");
  yylex ();
  fclose (yyin);
  fclose (yyout);
}
