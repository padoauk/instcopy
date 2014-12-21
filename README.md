Instcopy
============================================
Instcopy is a tool for copying files (in source code or build directories) to defined destinations.

Configuration of copying
============================================
Instcopy copies files in directories as defined in the configuration files in each directory.
Suppose the following files and directories exist. Configuration file, target.inst, in dir1 defines
to which file1 is copied and the file in dir2 defines to which file2 is copied.

```
  .
  `--dir1
  |   `-- target.inst
  |   `-- file1
  `--dir2
  |   `-- target.inst
  |   `-- file2
  `--target.inst
```

When instcopy.rb is invoked with "target" such as `instcopy.rb target`, it copies files according
to the definitions. If instcopy.rb is invoked such as `instropy.rb target2`, it follows to the
different set of configuration files, whose names are target2.inst. The file names of one set of
configurations are all same.

Top level configuration
---------------------------------------------
There's a top level configuration file in a set of configuration files. The directory in which
the top level configuration file exists can be specified by `-t top_dir` or `--top top_dir`.
If there's no such specification, instcopy.rb searchs the configuration files from the current
directory to directories above. If there's no configuration file in a directory for the specified
target, the search stops. The top level configuration file is the last configuration file found.

Global variable and its value can be specified in a top level configuration file. Here's an example.


```
TGT_APP  = /opt/app
TGT_DATA = /data/app
TGT_SYSS = "a b"
```

Copy configuration
---------------------------------------------
In configuration files which are not at the top level, file copy configurations are defined in YAML
format. YAML key represents destination directory and YAML value represents src file. The following
example defines that 'file1.txt' is copied to '/opt/app/bin', 'file2.txt' is copied to '/opt/app/sbin'
and 'data1.csv' is copied to '/data/app'.

```
- /opt/app:
  - bin:
    - file1.txt
  - sbin:
    - file2.txt
- /data/app:
  - data1.csv
```

Usage of global variables
---------------------------------------------
In the copy definition, the global variables defined in the top configuration file can be used. The
following is exactly same as the above.

```
- TGT_APP:
  - bin:
    - file1.txt
  - sbin:
    - file2.txt
- TGT_DATA:
  - data1.csv
```

Usage of global array variables
---------------------------------------------
Global array variables are those whose value is space seperated words. The TGT_SYSS in the above is
an example. When a global array variable is specified in copy configuration, the definition is maped
to all the elements of the array. For example,

```
- TGT_DATA/TGT_SYSS:
  - file_TGT_SYSS.txt
```

is equivalent to the following.

```
- TGT_DATA/a
  - file_a.txt
- TGT_DATA/b
  - file_b.txt
```



