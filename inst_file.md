Configuration files
====================================================
Instcopy reads configuration files in directories to define copy source files and thier destinations.

Filename
====================================================
Configuration files which instcopy reads in each invocation have common filename. When invoked with
"target-app", the common name is "target-app.inst". The suffix is .inst.

Top level configuration
====================================================
Top level .inst file locates in top directory. Top level directory can be specified in invocation
parameters. If it is not specified, instcopy searches configuration files from invoked current directory
to upper directories. In this case, the top level directory is the last directory in which the .inst
file exists.

In top level configuration files, configuration global parameters are specifiled. Parameters have either
scalar or array value. Here is the format definition.

Top level .inst foramat
----------------------------------------------------
'''
  definitions ::= { def_line | comment_line }
  def_line ::= top_level_var "=" top_level_val
  comment_line ::= "#" { ascii | space }
  top_level_var ::= { upper_alpha | "_" }
  top_level_val ::= scalar_val | array_val
  scalar_val ::= { ascii }
               | quote_single { ascii } quote_single
               | quote_double { ascii } quote_double
  array_val ::= quote_single scalar_val { " " scalar_val } quote_single
              | quote_double scalar_val { " " scalar_val } quote_double

  quote_single ::= "'"
  quote_double ::= "\""
  ascii ::= alpha_numeric | "/" | "_" | "." | "-" |
  alpha_numeric ::= upper_alpha | lower_alpha | digit
  upper_alpha ::= [A-Z]
  lower_alpha ::= [a-z]
  digit ::= [0-9]
  space ::= " " | "    "
'''

Top level .inst example
----------------------------------------------------
'''
  # top level copyinst definition for APP
  APP_BIN = /opt/app/bin
  APP_DATA = /var/app
  APP_CONF = /etc/app
  APP_SYSTEMS = "a b c d"
'''

Copy configuration
====================================================
In all the other .inst files, copy configuration is defined in YAML format. Hash keys are associated to
copy destination directory. Values are associated to source file in the same directory.  If value line matches
"original_file -> converted_file", original_file in the source directory is renamed to converted_file in the
destination directory.


Copy configuration .inst examples
-----------------------------------------------------

### copy config example 01

  # file1 and file2 are copied to /opt/bin
  - /opt/bin:
    - file1
    - file2

### copy config example 02

  # file1 and file2 are copied to /opt/bin
  - /opt:
    - bin:
      - file1
      - file2

### copy config example 03

  # src_file1 is copied to /opt/bin and renamed to dst_file1
  - /opt/bin:
    - src_file1 -> dst_file1


Referring global parameter
=======================================================
When variable name defined in top level .inst file are referred in copy .inst files, variable names are
replaced by parameter values.

Scalar parameter
-------------------------------------------------------
Each scalar parameter variable is simply replaced by its parameter value.

### top level configuration example

  TOP = /opt
  BIN = bin
  DATA = data
  SYSS = "a b c d"


### copy config example 04

  # file1 is copied to /opt/bin and file2 is copied to /opt/data
  - TOP:
    - BIN:
      - file1
    - DATA:
      - file2

Array parameter
-------------------------------------------------------
Each array parameter is replaced by all of its elements.

### copy config example 05

  # file1 is copied to /opt/data/a, /opt/data/b, /opt/data/c and /opt/data/d
  - TOP/DATA/SYSS:
    - file1

### copy config example 06

  # file1 is copied to /opt/data/file1a, /opt/data/file1b, /opt/data/file1c and /opt/data/file1d
  - TOP/DATA
    - file1SYSS
