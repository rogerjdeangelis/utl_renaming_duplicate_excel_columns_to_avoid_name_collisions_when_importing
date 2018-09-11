Renaming duplicate excel columns to avoid name collisions when importing

use suffix '_1' for same names in 2ns sheet.

INPUT
=====

   d:/xls/utl_renaming excel columns to avoid name collisions when importing.xlsx

   Sheet =hav1st

      +--------------------------------------+
      |     A      |    B       |     C      |
      +--------------------------------------+
   1  | NAME       |   SEX      |    AGE     |
      +------------+------------+------------+
   2  | ALFRED     |    M       |    14      |
      +------------+------------+------------+
       ...
      +------------+------------+------------+
   20 | WILLIAM    |    M       |    15      |
      +------------+------------+------------+

     [HAV1ST]


   Sheet =hav2nd

      +-------------------------+
      |    C       |    D       |
      +-------------------------+
   1  |  HEIGHT    |  WEIGHT    |
      +------------+------------+
   2  |    69      |  112.5     |
      +------------+------------+

      +------------+------------+
   20 |   66.5     |  112       |
      +------------+------------+
     [HAV1ST]


 EXAMPLE OUTPUT
 --------------
                                                                       *** RENAMED VARIABLES ***

      +----------------------------------------------------------------+--------------------------
      |     A      |    B       |     C      |    D       |    E       |     F      |     G      |
      +----------------------------------------------------------------+--------------------------
   1  | NAME       |   SEX      |    AGE     |  HEIGHT    |  WEIGHT    | NAME_1     |    AGE_1   |
      +------------+------------+------------+------------+------------+------------+------------+
   2  | ALFRED     |    M       |    14      |    69      |  112.5     | ALFRED     |    14      |
      +------------+------------+------------+------------+------------+------------+------------+
       ...                                                              ...
      +------------+------------+------------+------------+------------+------------+------------+
   20 | WILLIAM    |    M       |    15      |   66.5     |  112       | WILLIAM    |    15      |
      +------------+------------+------------+------------+------------+------------+------------+


PROCESS
 =======

libname xel "utl_renaming duplicate excel columns to avoid name collisions when importing.xlsx";

* get names hav1st sheet;
proc transpose data=xel.hav1st(obs=1)  out=hav1stNam(keep=_name_);
var _all_;
run;quit;

* get names hav2nd sheet;
proc transpose data=xel.hav2nd(obs=1)  out=hav2ndNam(keep=_name_);
var _all_;
run;quit;

/*
WORK.HAV1STNAM total obs=3

 _NAME_

  NAME
  SEX
  AGE
*/

* get common names;
proc sql;
   select
       l._name_
   into
       :nam separated by " "
   from
       hav1stNam as l, hav2ndNam as r
   where
      l._name_ = r._name_
;quit;

%put &=nam;

/*
NAM=NAME AGE
*/

%array(nams,values=&nam);

* RENAME;
data want;
  merge
     xel.hav1st xel.hav2nd(rename=(
        %do_over(nams,phrase=%str( ? = ?_1))
        ));
run;quit;

libname xel clear;  ** need this to close xel handle;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

* note this creates named ranges - you can substittute 'sheet$'n;

* JUST  IN CASE YOU WANT TO RERUN;
%utlfkil(d:/xls/utl_renaming excel columns to avoid name collisions when importing.xlsx);

libname xel "utl_renaming duplicate excel columns to avoid name collisions when importing.xlsx";

data xel.hav1st;
  set sashelp.class(keep=name age sex);
run;quit;

data xel.hav2nd;
  set sashelp.class(keep=name age height weight);
run;quit;

libname xel clear;

