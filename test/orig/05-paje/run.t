Using paje.conf:
  $ env BOLT_FILE=paje.conf ./main.exe > /dev/null
  $ cat paje.res | sed -e 's/[0-9]*\.[0-9]*/TIME/g' > paje.result
  $ diff paje.result paje.reference
