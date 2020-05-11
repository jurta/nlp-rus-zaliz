
#define WINFO 0x3F

#define GLAGOL_NESOVERSHENNOGO_VIDA              0x01
#define NEPEREHODNYJ_GLAGOL_NESOVERSHENNOGO_VIDA 0x02
#define GLAGOL_SOVERSHENNOGO_VIDA                0x03
#define NEPEREHODNYJ_GLAGOL_SOVERSHENNOGO_VIDA   0x04
#define DVUVIDOVOJ_GLAGOL                        0x05
#define NEPEREHODNYJ_DVUVIDOVOJ_GLAGOL           0x06
#define NEODUSH_SUSHCH_MUZHSKOGO_RODA_1          0x07
#define ODUSH_SUSHCH_MUZHSKOGO_RODA_1            0x08
#define ODUSH_NEODUSH_SUSHCH_MUZHSKOGO_RODA      0x09
#define NEODUSH_SUSHCH_MUZHSKOGO_RODA_2          0x0A
#define ODUSH_SUSHCH_MUZHSKOGO_RODA_2            0x0B
#define ODUSH_SUSHCH_MUZHSKOGO_RODA_3            0x0C
#define NEODUSH_SUSHCH_ZHENSKOGO_RODA            0x0D
#define ODUSH_SUSHCH_ZHENSKOGO_RODA              0x0E
#define ODUSH_NEODUSH_SUSHCH_ZHENSKOGO_RODA      0x0F
#define NEODUSH_SUSHCH_SREDNEGO_RODA             0x10
#define ODUSH_SUSHCH_SREDNEGO_RODA               0x11
#define ODUSH_NEODUSH_SUSHCH_SREDNEGO_RODA       0x12
#define NEODUSH_SUSHCH_OBSHCHEGO_RODA            0x13
#define ODUSH_SUSHCH_OBSHCHEGO_RODA              0x14
#define NEODUSH_SUSHCH_MUZHSKOGO_SREDNEGO_RODA   0x15
#define ODUSH_SUSHCH_MUZHSKOGO_SREDNEGO_RODA     0x16
#define NEODUSH_SUSHCH_ZHENSKOGO_SREDNEGO_RODA   0x17
#define NEODUSH_SUSHCH_MNOZHESTVENNOGO_CHISLA    0x18
#define PRILAGATELNYE_1                          0x19
#define PRILAGATELNYE_2                          0x1A
#define PRITJAZHATELNYE_MESTOIMENIJA             0x1B
#define MESTOIMENNYE_PRILAGATELNYE               0x1C
#define MESTOIMENIJA_1                           0x1D
#define MESTOIMENIJA_2                           0x1E
#define MESTOIMENIJA_3                           0x1F
#define MESTOIMENIJA_4                           0x20
#define CHISLITELNOE_1                           0x21
#define CHISLITELNOE_2                           0x22
#define SOBIRATELNOE_CHISLITELNOE                0x23
#define PORJADKOVOE_CHISLITELNOE                 0x24
#define IMENA_SOBSTVENNYE_1                      0x25
#define IMENA_SOBSTVENNYE_2                      0x26
#define IMENA_SOBSTVENNYE_3                      0x27
#define OTCHESTVA_1                              0x28
#define OTCHESTVA_2                              0x29
#define FAMILII                                  0x2A
#define GEOGRAFICHESKIE_NAZVANIJA_1              0x2B
#define GEOGRAFICHESKIE_NAZVANIJA_2              0x2C
#define GEOGRAFICHESKIE_NAZVANIJA_3              0x2D
#define GEOGRAFICHESKIE_NAZVANIJA_4              0x2E
#define GEOGRAFICHESKIE_NAZVANIJA_5              0x2F
#define VVODNOE_SLOVO                            0x30
#define MEZHDOMETE                               0x31
#define PREDIKATIV                               0x32
#define PREDLOG                                  0x33
#define SOJUZ                                    0x34
#define CHASTICA                                 0x35
#define NARECHIE                                 0x36
#define SOKRASHCHENNOE_SUSHCHESTVITELNOE         0x37
#define SOKRASHCHENNOE_PRILAGATELNOE             0x38
#define SOKRASHCHENNOE_VVODNOE_SLOVO             0x39
#define OBOSOBLENNAJA_SRAVNITELNAJA_STEPEN       0x3A
#define ABBREVIATURA_1                           0x3B
#define ABBREVIATURA_2                           0x3C

// Bits: VPPPCRRKSGGLLIII
#define INFINITIV                0x0001
#define POVELITELNOE_NAKLONENIE  0x0002
#define BUDUSHCHEE_VREMJA        0x0003
#define NASTOJASHCHEE_VREMJA     0x0004
#define PROSHEDSHEE_VREMJA       0x0005
#define LICO_1                   0x0008
#define LICO_2                   0x0010
#define LICO_3                   0x0018
#define LICHNAJA_FORMA_GLAGOLA   0x0000
#define DEJSTVITELNOE_PRICHASTIE 0x0020
#define STRADATELNOE_PRICHASTIE  0x0040
#define DEEPRICHASTIE            0x0060
#define SRAVNITELNAJA_STEPEN     0x0080
#define KRATKAJA_FORMA           0x0100
#define MUZHSKOJ_ROD             0x0200
#define ZHENSKIJ_ROD             0x0400
#define SREDNIJ_ROD              0x0600
#define CHISLO                   0x0800
#define IMENITELNYJ_PADEZH       0x0000
#define RODITELNYJ_PADEZH        0x1000
#define DATELNYJ_PADEZH          0x2000
#define VINITELNYJ_PADEZH        0x3000
#define TVORITELNYJ_PADEZH       0x4000
#define PREDLOZHNYJ_PADEZH       0x5000
#define RODITELNYJ_PADEZH_2      0x6000
#define PREDLOZHNYJ_PADEZH_2     0x7000
#define VOZVRATNAJA_FORMA        0x8000

#define GetCase( gInfo )  ( ( (gInfo) & 0x7000 )>>  12 )
#define GetGender( gInfo ) ( ( (gInfo) & 0x0600 )>>  9 )

struct _GramInfo
{
  short wInfo;
  short gInfo;
  short Flags;
};
typedef struct _GramInfo TGramInfo;

extern long GetVersion(
  unsigned char * szDest,
  int             DestLen,
  long            Reserved);

extern long CheckWord(
  unsigned char * lpszWord,
  int             Options,
  int             Lexicons);

extern int CreateNormalForms(
  unsigned char * pszWord,
  unsigned char * pszBuff,
  unsigned char * psGInfo,
  int             Options,
  int             BuffLen,
  int             InfoLen);

extern int SetWordForm(
  char * lpszWord,
  int    WordType,
  int    GramInfo,
  int    Animate,
  char * lpszBuff,
  int    BuffLen);
