#!/bin/bash -e

input=src
output=src-x16

if [ -z "$1" ] ; then
  sources=$(echo ${input}/*.asm)
else
  sources=$1
fi


for source in $sources; do
  outname=$(echo $source | sed s#$input/#$output/#)

  echo "Convert $source to $outname"

  #dos2unix $source -O |

   sed $source -E \
      -e 's#^\.([a-zA-Z0-9_]*)#\1:##' \
      -e 's#:\\# ;#' \
      -e 's#\\\\#;;#' \
      -e 's#\\#;#' \
      -e 's# EQUB#.byte #' \
      -e 's#:EQUB#\n.byte #g' \
      -e 's# EQUW#.word #' \
      -e 's#:EQUW#\n.word #g' \
      -e 's#^( [A-Z][A-Z][A-Z])# \1 #' \
      -e 's#:([A-Z][A-Z][A-Z])#\n  \1 #g' \
      -e 's#&([A-Za-z0-9]+)#$\1#' \
      -e 's#\#([A-Za-z0-9]+) MOD ([0-9]+)#\#(\1 .mod \2)#' \
      -e 's#\#([A-Za-z0-9]+) DIV ([0-9]+)#\#(\1 / \2)#' \
      > $outname

      # -e expressions above
      # .label -> label:
      # :\ comment -> ; comment
      # \\ comment -> ;; comment
      # \  comment -> ; comment
      # " LDAxxx" -> " LDA xxx"
      # ":LDAxxx" -> "\n LDAxxx" - break up multiple commands
      # &xxxx -> $xxxx - Hex conversion

done
