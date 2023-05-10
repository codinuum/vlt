Using daikon.conf:
  $ env BOLT_FILE=daikon.conf ./main.exe > /dev/null
  $ diff daikon-decls.result daikon-decls.reference
  $ diff daikon-dtrace.result daikon-dtrace.reference
