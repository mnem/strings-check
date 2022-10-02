# strings-check

[![Swift](https://github.com/mnem/strings-check/actions/workflows/swift.yml/badge.svg)](https://github.com/mnem/strings-check/actions/workflows/swift.yml)

A simple command line utility to check if translation strings are missing, or if extra translations are present in a set of `.strings` files. A base file is passed which is treated as the canonical set of translations strings, and additional `.strings` files are passed to compare against this canonical version.

An example may help explain this better. Consider that we have the following strings files:

```
#######################################
# a.strings
"key.a" = "First";
"key.b" = "Second";
"key.c" = "Third";

#######################################
# b.strings
"key.c" = "Third";
"key.b" = "Second";

#######################################
# c.strings
"key.a" = "First";
"key.c" = "Third";
"key.d" = "Fourth";

#######################################
# d.strings
"key.a" = "First";
"key.b" = "Second";
"key.c" = "Third";
```

From this we can see that compared to the base file, `a.strings`:
* `b.strings` is missing `"key.a"`
* `c.strings` is missing `"key.b"` but has an extra key of `"key.d"`
* `d.strings` has the same keys as the base file

We can get the tool to display this as follows, assuming that the tool is installed on your path:

```
strings-check --base a.strings d.strings b.strings c.strings
Base file: /Users/mnem/Development/github/mnem/strings-check/a.strings
  /Users/mnem/Development/github/mnem/strings-check/b.strings:
    - "key.a"
  /Users/mnem/Development/github/mnem/strings-check/c.strings:
    - "key.b"
    + "key.d"
  /Users/mnem/Development/github/mnem/strings-check/d.strings:
    Identical

```

NOTE: If the tool isn't on your path, you can run it by using `swift run` in the repository root, for example:

```
swift run strings-check --base a.strings d.strings b.strings c.strings
```
