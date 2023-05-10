# VLT - A Variant of Bolt OCaml Logging Tool

## Overview

This package provides yet another variant of [Bolt OCaml logging tool](http//bolt.x9c.fr)
called VLT derived from [Volt logging tool](https://github.com/codinuum/volt).
Unlike Volt, VLT relies on ppx instead of camlp4 to preprocess source code.
In addition to the original Bolt (except preprocessor), VLT offers the following features:

+ **Pass filter concept**
  Each logger has an associated pass filter, which ensures that events
  will never be propagated to the ancestor loggers when the events do
  not satisfy the filter.

+ **Original logging syntax modified for ppx**  
  log_expr ::= `[%LOG` level (string|ident) {arg}* {attr}* `]`  

  level ::=  
   | `[%FATAL]`  
   | `[%ERROR]`  
   | `[%WARN]`  
   | `[%INFO]`  
   | `[%DEBUG]`  
   | `[%TRACE]`  

  attr ::=  
   | `[%NAME` string `]`  
   | `[%`(`PROPERTIES` | `WITH`) expr `]`  
   | `[%`(`EXCEPTION` | `EXN`) expr `]`  
 
+ **Extended logging syntax**  
  log_expr ::= ...  
   | `[%fatal_log` (string|ident) {arg}* {attr}* `]`  
   | `[%error_log` (string|ident) {arg}* {attr}* `]`  
   | `[%warn_log` (string|ident) {arg}* {attr}* `]`  
   | `[%info_log` (string|ident) {arg}* {attr}* `]`  
   | `[%debug_log` (string|ident) {arg}* {attr}* `]`  
   | `[%trace_log` (string|ident) {arg}* {attr}* `]`  

  block_expr ::=  
   | `begin%fatal_block` expr_seq `end`  
   | `begin%error_block` expr_seq `end`  
   | `begin%warn_block` expr_seq `end`  
   | `begin%info_block` expr_seq `end`  
   | `begin%debug_block` expr_seq `end`  
   | `begin%trace_block` expr_seq `end`  

+ **More informative default logger name**
  In addition to a capitalized source file name without suffix,
  surrounding module names, class names, method names, or function names are
  used to compute a logger name, unless `[%NAME` ... `]` attribute is provided.
  Note that, unlike Volt, you have to enclose each toplevel structure_item in `[%%capture_path` ... `]`.

+ **Suppression of unwanted evaluation of arguments**
  Arguments in the `[%LOG` ... `]` and *`_log` expressions are not evaluated when the defined
  logger does not record events.

+ **Additional keys for use by the pattern and csv layouts.**  
  monthname - name of month e.g. January, February, ...  
  monthnm - abbreviated name of month e.g. Jan, Feb, ...

## Sources

The development sources are available from [GitHub](https://github.com/codinuum/vlt).

## License

As in the original version, this tool is free software released under the LGPLv3.

## Installation

    $ dune build
    $ dune install

## Original

The original Bolt is Copyright (C) 2009-2012 Xavier Clerc and released under the LGPLv3.
The official website of Bolt is [here](http://bolt.x9c.fr).

----------
Copyright &copy; 2023 [Codinuum Software Lab](http://codinuum.com/)