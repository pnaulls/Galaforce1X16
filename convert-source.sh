#!/bin/bash -e

input=src
output=src-x16

if [ -z "$1" ] ; then
  sources=$(echo ${input}/*.asm)
else
  sources=$1
fi

process () {
  statement=$1
  comment=$2

#  echo $statement

  echo -n "$statement" | sed -E \
      -e 's#&([A-Za-z0-9]+)#$\1#g' \
      -e 's#SKIP#\#SKIP#' \
      -e 's#INCLUDE #\#INCLUDE #' \
      -e 's#INCBIN #\#INCBIN #' \
      -e 's#\MAPCHAR#\#MAPCHAR#' \
      -e 's#PRINT# ; PRINT not implemented#' \
      -e 's#SAVE# ; SAVE not implemented#' \
      -e 's#PUTBASIC# ; PUTBASIC not implemented#' \
      -e 's#"src\\(.+\.asm")#"src-x16/\1#' \
      -e 's#"object\\(O\.)#"object/\1#' \
      -e 's#^[[:space:]]*\\#;#' \
      -e 's#^[[:space:]]*\.([a-zA-Z0-9_]*)#\1:##' \
      -e 's#EQUB#.byte #' \
      -e 's#EQUW#.word #' \
      -e 's#EQUD#.dword #' \
      -e 's#EQUS#.byte #' \
      -e '/:$/!s/^[[:space:]]*([A-Z][A-Z][A-Z])/ \1 /' \
      -e 's#([A-Za-z0-9_]+) MOD ([0-9]+)#(\1 .mod \2)#' \
      -e 's#([A-Za-z0-9_]+) DIV ([0-9]+)#(\1 / \2)#' \
      -e 's#([A-Za-z0-9_]+) EOR ([0-9]+)#(\1 .bitxor \2)#' \
      -e 's#\.byte[ \t]+(.*-.*)#.byte (\1) \& $ff#' \
      -e 's#\.word[ \t]+(.*-.*)#.word (\1) \& $ffff#' \
      -e 's#\s*ORG\s*0#.segment "ZEROPAGE"#' \
      -e 's#\s*ORG#.org#' \
      -e 's#^\s*\#MAPCHAR#;.charmap#' \
      -e 's#\s*\#INCLUDE#.include#' \
      -e 's#\s*\#INCBIN#.incbin#' \
      -e 's#\#SKIP#.res#' \
      -e 's#P%#*#' \
      -e 's#([A-Za-z0-9_]+)%#\1#' \
      >> $outname

       # EQUB -> .byte
       # EQUW -> .word
       # EQUD -> .dword
       # EQUS -> .byte (not .asciiz)
       # "LDAxxx" -> " LDA xxx" - format apparent opcodes and avoid labels
       # MOD -> .mod    - # expression
       # DIV -> /       - # expression
       # EOR -> .bitxor - # expression
       # .byte -N -> .byte (-N) & $ff -> Number in range for bytes
       # .word -N -> .word (-N) & $ff -> Number in range for words

#    sed -i $outname -E \

     # Address base handling

 #sed -i $outname -E \


    # Final formatting

  #  sed -i $outname -E \
#       -e 's#^[[:space:]]*\.#  .#' \
#       -e '/^;/!s/([^[[:space:]]);(.*)/\1 ; \2/'

  if [ -n "$comment" ] ; then
    echo $comment | \
      sed -E \
        -e 's#\\\\#;;#' \
        -e 's#\\#;#' >> $outname
  else
    echo >> $outname
  fi
}


for source in $sources; do
  outname=$(echo $source | sed s#$input/#$output/#)
  if [ "$outname" == "$source" ] ; then
    outname="$outname.asm"
  fi

  echo "Convert $source to $outname"
  rm -f $outname

      # -e expressions above
      # .label -> label:
      # :\ comment -> ; comment
      # \\ comment -> ;; comment
      # \  comment -> ; comment
      # Split lines with : when not comment at start
      # &xxxx -> $xxxx - Hex conversion
      # SKIP -> .res
      # INCLUDE -> .include
      # objstrt, objend, objexec -> TBA
      # MAPCHAR, INCBIN, PRINT, SAVE, PUTBASIC -> TBA
      # Windows -> Linux filename adjustment

      # .incbin


  cat $source | dos2unix |
  while read -r line; do
     #echo $line

    before=""
    comment=""
    found=false
    quote=false
    label=false

    length=${#line}
    for ((pos=0; pos<length; pos++ )); do
      char=${line:pos:1}

      if [ "$pos" == 0 ] ; then
        if [ "$char" == '.' ] ; then
          label=true
        fi
      fi

      if $label ; then
        tab_char=$'\t'

        if [ "$char" == ' ' -o "$char" == "$tab_char" ] ; then
          process "$before"
          before=""
          label=false
          continue
        fi

        before="${before}${char}"
        continue
      fi

      if [ "$char" == '"' ] ; then
        if $quote ; then quote=false; else quote=true; fi
      elif [ "$char" == '\' ] ; then
        if ! $quote; then
          found=true
        fi
      elif [ "$char" == ':' ] ; then
         if ! $quote; then
           process "$before" "$comment"
           before=""
           continue
         fi
      fi

      if ! $found; then
        before="${before}${char}"
      else
        comment="${comment}${char}"
      fi
    done

    process "$before" "$comment"

    #echo "$before ;; $comment"

  done


done
