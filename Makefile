# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This is free software; see the file COPYING for copying conditions.

VERSION = 0.0.1

# source files
SRCFILES = Z_160 Z_161 Z_162 Z_163 Z_164 Z_165 Z_166 Z_167 Z_168 Z_169 \
           Z_170 Z_171 Z_172 Z_173 Z_174 Z_175 Z_175A \
           Z_224 Z_225 Z_226 Z_227 Z_228 Z_229 \
           Z_230 Z_231 Z_232 Z_233 Z_237 Z_238 Z_239

# subpatches
DICT_P_1_1 = z.1.1.subpatch
DICT_P_1_2 = z.1.2.subpatch
DICT_P_2_1 = z.2.1.subpatch
DICT_P_2_2 = z.2.2.subpatch

# subpatch for exceptions
DICT_P_X = z.x.subpatch

# base filename
DICT      = zaliz
# patched dictionary
DICT_TXT  = $(DICT).txt
# word list
DICT_LST  = $(DICT).lst
# Association DataBase (ADB) with association lists of key-value pairs
DICT_ADB  = $(DICT).adb
# Association DataBase with infection indexes
DICT_ADB2 = $(DICT)2.adb
# file with common suffix indexes
DICT_SUF2 = $(DICT)2.suf
# file with accent indexes
DICT_ACC2 = $(DICT)2.acc
# Association DataBase with valid forms
DICT_ADB3 = $(DICT)3.adb
# file with common suffix indexes for valid forms
DICT_SUF3 = $(DICT)3.suf
# file with accent indexes for valid forms
DICT_ACC3 = $(DICT)3.acc
# yranoitcid desrever
DICT_REV  = $(DICT).rev
# tsildrow desrever
DICT_REV_LST  = $(DICT).rev.lst

PLFILES  = \
	adb2suf.pl \
	z2txt.pl \
	txt2adb.pl \
	txt2rev.pl

MAINFILES = ChangeLog Makefile README \
	$(PLFILES)

DATAFILES = \
	$(DICT_TXT) $(DICT_LST) $(DICT_ADB) \
	$(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2) \
	$(DICT_ADB3) $(DICT_SUF3) $(DICT_ACC3) \
	$(DICT_REV) $(DICT_REV_LST)

MAINDISTNAME = zaliz-$(VERSION)
DATADISTNAME = zaliz-dat-$(VERSION)

default: suf

all: suf rev

## Correct errors in the source dictionary
txt: $(DICT_TXT)
$(DICT_TXT): $(SRCFILES) z2txt.pl $(DICT_P_1_1) $(DICT_P_1_2)
	perl z2txt.pl $(SRCFILES) \
	| perl subpatch.pl $(DICT_P_1_1) \
	| perl subpatch.pl $(DICT_P_1_2) \
	> $(DICT_TXT)

## Make Associative DataBase (ADB) file from source
adb: $(DICT_ADB)
$(DICT_ADB): $(DICT_TXT) txt2adb.pl $(DICT_P_2_1) $(DICT_P_2_2) $(DICT_P_X)
	cat $(DICT_TXT) \
	| perl subpatch.pl $(DICT_P_2_1) \
	| perl subpatch.pl $(DICT_P_2_2) \
	| LANG=ru_RU.KOI8-R perl txt2adb.pl $(DICT_P_X) \
	> $(DICT_ADB) 2> $(DICT_ADB).err

## Make suffix paradigm lists from source
suf: $(DICT_SUF2)
$(DICT_SUF2): $(DICT_ADB) $(DICT_LST) adb2suf.pl
	perl adb2suf.pl $(DICT_ADB) $(DICT_SUF2) $(DICT_ACC2) $(DICT_LST) > $(DICT_ADB2) 2> $(DICT_ADB2).err
#	perl adb2suf.pl $(DICT_LST) > $(DICT_SUF2).err 2>&1

## Create word list
lst: $(DICT_LST)
$(DICT_LST): $(DICT_ADB)
	perl adb2lst.pl $(DICT_ADB) | LANG=ru_RU.KOI8-R sort -u > $(DICT_LST)

### Extra files (their generation can take signicant amount of memory and time)

# TODO: try program "rev"
## Create reversed dictionary and list of reversed words
rev: $(DICT_REV) $(DICT_REV_LST)
$(DICT_REV) $(DICT_REV_LST): $(DICT_TXT) $(DICT_LST)
	LANG=ru_RU.KOI8-R perl -Mlocale txt2rev.pl $(DICT_TXT) > $(DICT_REV)
	LANG=ru_RU.KOI8-R perl -Mlocale txt2rev.pl $(DICT_LST) > $(DICT_REV_LST)

## Generate all wordforms simple, unique and sorted
wf: $(DICT).wf.sort.u.all
$(DICT).wf.sort.u.all: # $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2)
	perl priparad.pl -wf $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2) | sort -u > $(DICT).wf.sort.u.all

## Generate all wordforms with word info, unique and sorted
wfa: $(DICT).wfa.sort.u.all
$(DICT).wfa.sort.u.all: # $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2)
	perl priparad.pl -wfa $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2) | sort -u > $(DICT).wfa.sort.u.all

## Generate all homoforms
hf: $(DICT).hf.sort.u.all
$(DICT).hf.sort.u.all: # $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2)
	perl priparad.pl -hf $(DICT_ADB2) $(DICT_SUF2) $(DICT_ACC2) | sort -u > $(DICT).hf.sort.u.all

## Reverse all wordforms and generate palindrome list
palindrome: $(DICT).wf.rev.sort.u.all
$(DICT).wf.rev.sort.u.all: $(DICT).wf.sort.u.all
	perl -lne 'print scalar reverse' $(DICT).wf.sort.u.all | sort -u > $(DICT).wf.rev.sort.u.all
	comm -12 $(DICT).wf.sort.u.all $(DICT).wf.rev.sort.u.all > $(DICT).wf.palindrome

## TODO: priparad -full

### Maintenance targets

## Check correctness of all subpatch files
check-subpatch:
	perl -n util/subpatch-check.pl $(DICT_P_1_1) $(DICT_P_1_2) $(DICT_P_2_1) $(DICT_P_2_2)

## Locate all version strings
check-versions:
	grep -in -e "version.*[0-9]\.[0-9]" $(MAINFILES)

install:

clean:
	rm -f $(DICT_TXT) $(DICT_ADB)

$(MAINDISTNAME).tar.gz: $(MAINFILES)
	rm -rf $(MAINDISTNAME)
	mkdir -p $(MAINDISTNAME)
	cp -p $(MAINFILES) $(MAINDISTNAME)
	tar -cvzf $(MAINDISTNAME).tar.gz $(MAINDISTNAME)
	rm -rf $(MAINDISTNAME)
	ls -l *.tar.gz

$(DATADISTNAME).tar.gz: $(DATAFILES)
	rm -rf $(DATADISTNAME)
	mkdir -p $(DATADISTNAME)
	cp -p $(DATAFILES) $(DATADISTNAME)
	tar -cvzf $(DATADISTNAME).tar.gz --owner=0 --group=0 $(DATADISTNAME)
	rm -rf $(DATADISTNAME)
	ls -l *.tar.gz

dist: $(MAINDISTNAME).tar.gz $(DATADISTNAME).tar.gz

# Commands that should be executed, printed by "make -n" (not updated):
# perl z2txt.pl Z_160 Z_161 Z_162 Z_163 Z_164 Z_165 Z_166 Z_167 Z_168 Z_169 Z_170 Z_171 Z_172 Z_173 Z_174 Z_175 Z_175A Z_224 Z_225 Z_226 Z_227 Z_228 Z_229 Z_230 Z_231 Z_232 Z_233 Z_237 Z_238 Z_239 | perl subpatch.pl z.1.1.subpatch | perl subpatch.pl z.1.2.subpatch > z.txt
# cat z.txt | perl subpatch.pl z.2.1.subpatch | perl subpatch.pl z.2.2.subpatch | perl txt2adb.pl > z.adb 2> z.adb.err
# perl adb2lst.pl z.adb | LANG=ru_RU.KOI8-R sort -u > z.lst
# perl adb2suf.pl z.lst > z.suf.err 2>&1
