#include <stdio.h>
#include <gdbm.h>

char *inflexs[] = {"ие","ре","де","те","пе","им","рм","дм","тм","пм",NULL};
char *vowels = "аеёиоуыэюя";

char *postfixes[] = {  };

int
main (argc, argv)
     int argc;
     char *argv[];
{
  char *gdbfname = "../zaliz.dbm";
  char *word;
  char *winfo;
  char buffer[257];
  datum key;
  datum found;

  GDBM_FILE dbf = gdbm_open(gdbfname, 0, GDBM_READER, 0, NULL);
  if (!dbf) {
    fprintf(stderr, "GDBM File %s not found.\n", gdbfname);
    return -1;
  }

  while (fgets (buffer, sizeof (buffer), stdin) != NULL) {
    buffer[strlen(buffer)-1] = '\0'; /* chop */
    word = buffer;
    key.dptr = word;
    key.dsize = strlen (key.dptr);
    found = gdbm_fetch (dbf, key);
    winfo = found.dptr;
    if (winfo) {
      int i = 0;
      char *inflex;
      char r = winfo[0], t = winfo[1], ch = winfo[2];
      char t2;
      char *s;
      if (r != 'м' && r != 'ж' && r != 'с')
        continue;
      switch(t) {
        case '1': case '3': case '4': case '5': t2 = 1; break;
        case '2': case '6': case '7':           t2 = 2; break;
        case '8':                               t2 = 8; break;
      }
      s = word + strlen(word) - 1;
      if (strchr (vowels, *s) || strchr ("йь", *s))
        *s = '\0';
      if (ch == '*')
        strcpy (s-1, s);
      printf("%c:%d:%c:%s:%s\n", r, t2, ch, s, word);
      while (inflex = inflexs[i]) {
        char p = inflex[0], c = inflex[1];
        char *postfix = "";
        if (p == 'и' && c == 'е' && r == 'м' && t2 == 1) ;
        if (p == 'д' && c == 'м' && t2 == 1) postfix = "ам";
/*         ""    => "ием1|рм[сж]1", */
/*         "ь"   => "ием2|рм[сж]2|[ив]е.8", */
/*         "а"   => "ре[мс]1|иеж1|имс1", */
/*         "я"   => "ре[мс]2|иеж2|имс2", */
/*         "ам"  => "дм[мсж]1", */
/*         "ям"  => "дм[мсж]2", */
/*         "ами" => "тм[мсж]1", */
/*         "ями" => "тм[мсж]2", */
/*         "ах"  => "пм[мсж]1", */
/*         "ях"  => "пм[мсж]2", */
/*         "о"   => "иес1", */
/*         "е"   => "иес2|деж[12]|пе[мсж][12]", */
/*         "ей"  => "теж2|рм[мсж]2", */
/*         "ею"  => "теж2|рм[мсж]2", */
/*         "ов"  => "рмм1", */
/*         "ой"  => "теж1", */
/*         "ою"  => "теж1", */
/*         "ом"  => "те[мс]1", */
/*         "ем"  => "те[мс]2|те[мс]8", */
/*         "ы"   => "реж1|им[жм]1", */
/*         "и"   => "реж2|им[мж]2|[рдп]е.8", */
/*         "у"   => "де[мс]1|веж1", */
/*         "ю"   => "де[мс]2|веж2", */
/*         "ью"  => "теж8", */
        printf("%s: %s%s:\n", inflex, word, postfix);
        i++;
      }
    } else {
      fprintf(stderr, "%s: Not found.\n", word);
    }
  }







































































  gdbm_close(dbf);
  return 0;
}
