Using simple.conf:
  $ env BOLT_FILE=simple.conf ./main.exe abc def ghi > /dev/null
  $ diff simple.result simple.reference
