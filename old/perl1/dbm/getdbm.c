#include <stdio.h>
#include <gdbm.h>

char *inflexs[] = {"��","��","��","��","��","��","��","��","��","��",NULL};
char *vowels = "�ţ�������";

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
      if (r != '�' && r != '�' && r != '�')
        continue;
      switch(t) {
        case '1': case '3': case '4': case '5': t2 = 1; break;
        case '2': case '6': case '7':           t2 = 2; break;
        case '8':                               t2 = 8; break;
      }
      s = word + strlen(word) - 1;
      if (strchr (vowels, *s) || strchr ("��", *s))
        *s = '\0';
      if (ch == '*')
        strcpy (s-1, s);
      printf("%c:%d:%c:%s:%s\n", r, t2, ch, s, word);
      while (inflex = inflexs[i]) {
        char p = inflex[0], c = inflex[1];
        char *postfix = "";
        if (p == '�' && c == '�' && r == '�' && t2 == 1) ;
        if (p == '�' && c == '�' && t2 == 1) postfix = "��";
/*         ""    => "���1|��[��]1", */
/*         "�"   => "���2|��[��]2|[��]�.8", */
/*         "�"   => "��[��]1|���1|���1", */
/*         "�"   => "��[��]2|���2|���2", */
/*         "��"  => "��[���]1", */
/*         "��"  => "��[���]2", */
/*         "���" => "��[���]1", */
/*         "���" => "��[���]2", */
/*         "��"  => "��[���]1", */
/*         "��"  => "��[���]2", */
/*         "�"   => "���1", */
/*         "�"   => "���2|���[12]|��[���][12]", */
/*         "��"  => "���2|��[���]2", */
/*         "��"  => "���2|��[���]2", */
/*         "��"  => "���1", */
/*         "��"  => "���1", */
/*         "��"  => "���1", */
/*         "��"  => "��[��]1", */
/*         "��"  => "��[��]2|��[��]8", */
/*         "�"   => "���1|��[��]1", */
/*         "�"   => "���2|��[��]2|[���]�.8", */
/*         "�"   => "��[��]1|���1", */
/*         "�"   => "��[��]2|���2", */
/*         "��"  => "���8", */
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
