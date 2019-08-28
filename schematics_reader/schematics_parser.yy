%define parse.error verbose
%define api.parser.class {SchematicsParser}
%define api.prefix {schematics}
%language "c++"

%code requires {
	namespace schematics {
		class SchematicsData;
	}
}
%param {schematics::SchematicsData *schematicsdata}

%{
#include <iostream>
#include <string>

#include <QString>
#include <QMap>
#include <QStack>

#include "schematicsscanner.h"
#include "schematicsdata.h"

#define schematicslex (schematicsdata->getLexer())->schematicslex
#define schematicslineno (int)(schematicsdata->getLexer())->lineno()
#define schematicstext (schematicsdata->getLexer())->YYText()

%}

%union {
	std::string* v_str;
	double v_double;
	int v_int;
}

%token BEGIN_SCHEMATIC
%token HASH
%token LIBS
%token EELAYER

%token COMPONENT
%token COMPONENT_L
%token COMPONENT_U
%token COMPONENT_P
%token COMPONENT_F
%token END_COMPONENT

%token DESCR
%token DESCR_ENC
%token DESCR_SHEET
%token DESCR_TITLE
%token DESCR_DATE
%token DESCR_REVISION
%token DESCR_COMP
%token DESCR_COMMENT
%token END_DESCR

%token TEXT
%token WIRE
%token CONNECTION

%token END_SCHEMATIC

%token <v_int> INTEGER
%token <v_str> STRING
%token <v_double> DOUBLE

%start schematics_file

%%

schematics_file: BEGIN_SCHEMATIC schematics_entries END_SCHEMATIC;

schematics_entries:
	| schematics_entry
	| schematics_entries schematics_entry
;

schematics_entry:
	| library
	| eelayer
	| description
	| component
	| text
	| wire
	| connection
;

library: LIBS STRING;
eelayer:
	  EELAYER INTEGER INTEGER
	| EELAYER STRING
;

description:
DESCR STRING INTEGER INTEGER description_list END_DESCR
{
	schematicsdata->setFormat(*$2,$3,$4);
};

description_list:
	  description_content
	| description_list description_content
;

description_content:
	| DESCR_ENC STRING
	| DESCR_SHEET INTEGER INTEGER
	| DESCR_TITLE STRING
	| DESCR_DATE STRING
	| DESCR_REVISION STRING
	| DESCR_COMP STRING
	| DESCR_COMMENT STRING
;

component: COMPONENT component_list END_COMPONENT;

component_list:
	| component_content
	| component_list component_content
;

component_content:
| COMPONENT_L STRING STRING
{
	schematicsdata->setRecentPart(*$2,*$3);
}
| COMPONENT_L STRING

| COMPONENT_U INTEGER INTEGER STRING
| COMPONENT_U INTEGER INTEGER

| COMPONENT_P INTEGER INTEGER
{
	schematicsdata->setRecentPartPosition($2,$3);
}

| COMPONENT_F INTEGER STRING STRING INTEGER INTEGER INTEGER INTEGER STRING STRING
| COMPONENT_F INTEGER STRING STRING INTEGER INTEGER INTEGER INTEGER STRING
| COMPONENT_F INTEGER STRING STRING INTEGER INTEGER INTEGER INTEGER

| INTEGER INTEGER INTEGER
| INTEGER INTEGER INTEGER INTEGER
;

text: TEXT STRING INTEGER INTEGER INTEGER INTEGER STRING STRING INTEGER STRING;

wire:
WIRE WIRE STRING INTEGER INTEGER INTEGER INTEGER
{
	schematicsdata->addWire(*$3,$4,$5,$6,$7);
};

connection: CONNECTION STRING INTEGER INTEGER;

%%

void schematics::SchematicsParser::error(const std::string &s) {
	std::cout << "Error message: " << s << " on line " << schematicslineno << " yytext: " << schematicstext << std::endl;
}
