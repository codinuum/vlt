Using bymodule.conf:
  $ env BOLT_CONFIG=bymodule.conf ./main.exe abc def ghi > /dev/null
  $ diff bymodule.result bymodule.reference
  $ diff bymodule1.result bymodule1.reference
  $ diff bymodule2.result bymodule2.reference

Using csv.conf:
  $ env BOLT_CONFIG=csv.conf ./main.exe abc def ghi > /dev/null
  $ diff csv.result csv.reference

Using filter.conf:
  $ env BOLT_CONFIG=filter.conf ./main.exe abc def ghi > /dev/null
  $ diff filter.result filter.reference

Using level.conf:
  $ env BOLT_CONFIG=level.conf ./main.exe abc def ghi > /dev/null
  $ diff level.result level.reference

Using pattern.conf:
  $ env BOLT_CONFIG=pattern.conf ./main.exe abc def ghi > /dev/null
  $ diff pattern.result pattern.reference

Using simple.conf:
  $ env BOLT_CONFIG=simple.conf ./main.exe abc def ghi > /dev/null
  $ diff simple.result simple.reference

Using simple2.conf:
  $ env BOLT_CONFIG=simple2.conf ./main.exe abc def ghi > /dev/null
  $ diff simple1.result simple1.reference
  $ diff simple2.result simple2.reference
