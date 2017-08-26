%define api.prefix {magic}
%defines "magic.yy.h"
%error-verbose
%language "c++"
%glr-parser
%debug
%token-table
%define "parser_class_name" {MagicParser}

%code requires {
	namespace magic {
		class MagicData;
	}
}

%param {class magic::MagicData *magicdata}

%{
#include <iostream>
#include <string>
#include <QString>
#include "magicdata.h"

#define magiclex (magicdata->getLexer())->magiclex
#define magiclineno (int)(magicdata->getLexer())->lineno()

%}

%union {
	int v_int;
	std::string* v_str;
	double v_double;
}

%token PORT
%token BOX
%token TRANSFORM
%token MAGIC
%token TECH
%token MAGSCALE
%token TIMESTAMP
%token BEGINTITLE
%token ENDTITLE
%token USE

%token RECT
%token RLABEL
%token FLABEL

%token INTEGER
%type <v_int> INTEGER
%token STRING
%type <v_str> STRING
%token DOUBLE
%type <v_double> DOUBLE

%start magic_file
%%
magic_file: MAGIC technology magscale timestamp sections;
technology: TECH STRING;
magscale: MAGSCALE INTEGER INTEGER;
timestamp: TIMESTAMP INTEGER;
sections: sections section | section;
section:
		  BEGINTITLE sectiontitle ENDTITLE items;
		| BEGINTITLE sectiontitle ENDTITLE;
sectiontitle: STRING
	{
		magicdata->setLayer($1);
	}
	;

items: items item | item ;

item: rect | rlabel | flabel | use;

use: USE STRING STRING timestamp transform box;
transform: TRANSFORM INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER;
box:
	BOX INTEGER INTEGER INTEGER INTEGER
	{
		magicdata->addBox($2, $3, $4 - $2, $5 - $3);
	}
	;

rect:
	RECT INTEGER INTEGER INTEGER INTEGER
	{
		magicdata->addRectangle($2, $3, $4 - $2, $5 - $3);
	}
    ;

rlabel:
	RLABEL STRING
	INTEGER INTEGER INTEGER INTEGER INTEGER
	STRING
    ;

flabel:
	FLABEL STRING
	INTEGER INTEGER INTEGER INTEGER INTEGER
	STRING
	INTEGER INTEGER INTEGER INTEGER
	STRING
	port
	;

port: PORT INTEGER STRING;

%%

void magic::MagicParser::error(const std::string &s) {
	std::cout << "Error message: " << s << " on line " << magiclineno << std::endl;
}
