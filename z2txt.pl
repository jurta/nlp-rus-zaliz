#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# License: GNU GPL 2 (see the file README)

# Предварительная обработка исходных файлов:
# преобразование исходных файлов с именем Z_<номер>
# в один текстовый файл zaliz.txt.

# perl z2txt.pl Z_* > z.txt

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

print <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

# Дата: $currtime
# Генератор: $PROGRAM v$VERSION http://.../zaliz/index.ru.html

# ;; Date: $currtime
# ;; Generator: ell.pl v$version from http://.../ee/
# ;; Source: http://www/ell.html ($filetime)

# сгенерировано (сконвертировано, порождено, произведено) 2003-03-12
# генератором (производителем) http://.../zaliz/conv/ version: 0.0.1
# из http://starling.rinet.ru/download/dicts.EXE (дата: 2003-01-05, размер: 3964665)
# Источник: http://starling.rinet.ru/download/dicts.EXE (дата: 2003-01-05, размер: 3964665)

my %seen;

while (<>) {
  chomp;
  s/\r$//o;                     # удалить символ \r (CR, return) в конце строки
  s/\004.*$//;                  # удалить перевод слова на английский язык
  s/^\*//;                      # удалить звёздочки в начале строки
  s/\s+$//;                     # удалить пробелы в конце строки
  next if/^$/;                  # пропустить пустые строки
  next if $seen{$_}++;          # пропустить дубликаты
  # перевести буквы с ударением в заглавные буквы
  tr(╟╡╣╥╧╬бдфй╠╢╦╫кЪ)
    (─┘П┬▌⌠⌡²·÷─┘┬▌÷©);
  # сменить кодировку с CP866 на KOI8-R
  tr(─│┌┐└┘П├┤┬┴┼▀▄█▌▐░▒▓⌠■∙√≈≤≥ ⌡°²·÷═║╒ё╓╔Я╕╖╗╘╙╚╛╜╝╞ЮАБЦДЕФГХИЙКЛМНО)
    (АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя);
  print "$_\n";
}
