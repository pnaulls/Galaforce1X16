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
  if [ "$outname" == "$source" ] ; then
    outname="$outname.asm"
  fi

  echo "Convert $source to $outname"

  #dos2unix $source -O |

   sed $source -E \
      -e 's#:\\# ;#' \
      -e 's#\\\\#;;#' \
      -e 's#^[[:space:]]*\\#;#' \
      -e 's#("[^"]*")\\#\1;#' \
      -e '/^;/!s/:/\n/g' \
      -e 's#^\.([a-zA-Z0-9_]*)#\1:##' \
      -e 's#EQUB#.byte #g' \
      -e 's#EQUW#.word #g' \
      -e 's#EQUS#.byte #g' \
      -e 's#&([A-Za-z0-9]+)#$\1#g' \
      -e 's#(\s)SKIP(\s)#\1.res\2#' \
      -e 's#(\s)INCLUDE #.include #' \
      -e 's#(obj[a-z]+%)# ; \1 not implemented#' \
      -e 's#\sobjcodeend# ; objcodeend not implemented#' \
      -e 's#\MAPCHAR# ; MAPCHAR not implemented#' \
      -e 's#\s*ORG# ; ORG not implemented#' \
      -e 's#\sINCBIN# ; INCBIN not implemented#' \
      -e 's#\sPRINT# ; PRINT not implemented#' \
      -e 's#\sSAVE# ; SAVE not implemented#' \
      -e 's#\sPUTBASIC# ; PUTBASIC not implemented#' \
      -e 's#("src)\\(.+\.asm")#"src-x16/\2#' \
      > $outname

    # Break up matches that rely on start of line, after earlier splitting
    sed -i $outname -E \
       -e 's#^[[:space:]]*([A-Z][A-Z][A-Z])# \1 #' \
       -e 's#([A-Za-z0-9_]+) MOD ([0-9]+)#(\1 .mod \2)#' \
       -e 's#([A-Za-z0-9_]+) DIV ([0-9]+)#(\1 / \2)#' \
       -e 's#([A-Za-z0-9_]+) EOR ([0-9]+)#(\1 .bitxor \2)#' \


      # -e expressions above
      # .label -> label:
      # :\ comment -> ; comment
      # \\ comment -> ;; comment
      # \  comment -> ; comment
      # EQUB -> .byte
      # EQUW -> .word
      # " LDAxxx" -> " LDA xxx"
      # ":LDAxxx" -> "\n LDAxxx" - break up multiple commands
      # &xxxx -> $xxxx - Hex conversion
      # MOD -> .mod - # expression
      # DIV -> /    - # expression
      # SKIP -> .res

done
