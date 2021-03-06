#!/bin/bash

  SHORTURLBASE="http://lfkn.de"
  TMP="XX";QRSEED=`echo $* | sed 's/ /\n/g' | grep -v '^--'`
# --------------------------------------------------------------------------- #
  SHORTURL=`echo $*            | #
            sed 's/ /\n/g'     | #
            grep '^--shorturl' | #
            cut -d '=' -f 2`
   NOLABEL=`echo $*            | #
            sed 's/ /\n/g'     | #
            grep '^--nolabel'`   #
    ENCODE=`echo $*            | #
            sed 's/ /\n/g'     | #
            grep '^--encode'   | #
            cut -d '=' -f 2`
       OUT=`echo $*            | #
            sed 's/ /\n/g'     | #
            grep '^--out'      | #
            cut -d '=' -f 2`;       if [ "$OUT" == "" ];then OUT="qr";fi
# --------------------------------------------------------------------------- #
  function w() { echo "$*" >> $W; }
# --------------------------------------------------------------------------- #
  function shortRef() { ID1=`echo $*          | #
                             cut -d " " -f 1  | #
                             sed 's/ //g'     | #
                             md5sum           | #
                             base64           | #
                             cut -c 1-3`        # 
                        ID2=`echo $*          | #
                             cut -d " " -f 2- | #
                             sed 's/ //g'     | #
                             md5sum           | #
                             base64           | #
                             cut -c 4-5`        # 
                         echo "${ID1}${ID2}"
  }
# --------------------------------------------------------------------------- #
  if [ "$ENCODE" == "" ]
  then # -------------------------------------- #
       if [ "$SHORTURL" == "" ]
       then  QRURL=`shortRef $QRSEED      | #
                    tr [:lower:] [:upper:]` #
       else  QRURL=`echo $SHORTURL        | #
                    tr [:lower:] [:upper:]` #
       fi  # -------------------------------- #
             QRCONTENT="$SHORTURLBASE/$QRURL"
       # -------------------------------------- #
  else       QRCONTENT="$ENCODE"
  fi;        echo "$QRCONTENT"
# --------------------------------------------------------------------------- #
  echo "$QRCONTENT" | qrencode -iv 1 -m 0 -t EPS -o ${TMP}.eps
  inkscape --export-plain-svg=${TMP}.1.svg ${TMP}.eps
# --------------------------------------------------------------------------- #
  W="${TMP}.2.svg";if [ -f $W ];then rm $W;fi
# --------------------------------------------------------------------------- #
  w '<svg width="200" height="200" xml:space="preserve"'
  w ' id="svg" version="1.1" inkscape:version="0.48.3.1 r9886"'
  w ' xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"'
  w ' xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd">'
  w '<sodipodi:namedview id="namedview" inkscape:pageshadow="2"'
  w '                    pagecolor="#ffffff" bordercolor="#666666">'
  w '<sodipodi:guide position="67,130"  orientation="0,63"  id="1" />'
  w '<sodipodi:guide position="130,130" orientation="63,0"  id="2" />'
  w '<sodipodi:guide position="130,67"  orientation="0,-63" id="3" />'
  w '<sodipodi:guide position="67,67"   orientation="-63,0" id="4" />'
  w '<sodipodi:guide position="61,136"  orientation="0,75"  id="5" />'
  w '<sodipodi:guide position="136,136" orientation="75,0"  id="6" />'
  w '<sodipodi:guide position="136,61"  orientation="0,-75" id="7" />'
  w '<sodipodi:guide position="61,61"   orientation="-75,0" id="8" />'
  w '</sodipodi:namedview>'
  w '<g id="f" inkscape:groupmode="layer" inkscape:label="FRAME">'
  w '<path id="frame" d="m 61,64 75,0 L 136,139 61,139 z"'
  w '       style="fill:#ffffff;stroke:#000000;stroke-width:1px;"/>'
  w '</g>'
  if [ "$ENCODE" != "" ] || [ "$NOLABEL" == "" ]
  then  w '<g id="l" inkscape:label="LABEL" inkscape:groupmode="layer">'
        w '<text id="label" x="62" y="155"'
        w '      xml:space="preserve"'
        w '      sodipodi:linespacing="125%"'
        w '      style="font-family:Roboto Mono;'
        w '             -inkscape-font-specification:Roboto Mono Medium;'
        w '             font-size:14px;font-style:normal;font-variant:normal;'
        w '             font-weight:500;font-stretch:normal;text-indent:0;'
        w '             text-align:start;text-decoration:none;'
        w '             line-height:125%;letter-spacing:8px;word-spacing:0px;'
        w '             text-transform:none;direction:ltr;'
        w '             block-progression:tb;writing-mode:lr-tb;'
        w '             text-anchor:start;baseline-shift:baseline;'
        w '             fill:#000000;stroke:none;"><tspan id="t"'
        w "      sodipodi:role=\"line\">$QRURL</tspan></text>"
        w '</g>'
  fi
# --------------------------------------------------------------------------- #
  QRW=`identify -format "%w" ${TMP}.eps`
  S1="0.1055";S2=`python -c "print 63.00 / $QRW"`
  S=`python -c "print round($S1 * $S2,4)"`
  SCALE="scale($S,-$S)";MOVE="translate(65,135)"
  TRANSFORMQR="transform=\"$MOVE$SCALE\""
  w "<g $TRANSFORMQR>"
  sed ':a;N;$!ba;s/\n/ /g' ${TMP}.1.svg | #
  tr -s ' ' | sed 's/</\n&/g' | grep "^<path" >> $W
  w '</g>'
  w '</svg>'
# --------------------------------------------------------------------------- #
  inkscape --export-pdf=${OUT}.pdf \
           --export-text-to-path   \
           $W
# --------------------------------------------------------------------------- #
  if [ `echo ${TMP} | wc -c` -ge 2 ] &&
     [ `ls ${TMP}*.* 2>/dev/null | wc -l` -gt 0 ]
  then  rm ${TMP}*.* ;fi

exit 0;
