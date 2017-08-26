%{
  #include <stdio.h>
%}
letra [a-zA-z]
digito [0-9]
%%
[ \t\n]+                    {}
{letra}({letra}|{digito})*  { return 1; }
"@if"                       { return 2; }
"@else"                     { return 3; }
{digito}+                   { return 4; }
{digito}*"."{digito}+       { return 5; }
[{}()]                      { return 6; }
[<>]                        { return 7; }
=                           { return 8; }
.                           { printf("Error léxico\n"); }
%%
int
yywrap (void) {
  return 1;
}

int
main(void) {
  yylex ();
  return 0;
}
