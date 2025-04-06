#!/bin/bash
set -euo pipefail #bash strict mode
IFS=$'\t\n'

if [ "$#" -ge 2 ] || [ "$#" -eq 1 ] && ! [ "$#" -a "$1" = "-inplace" -o "$1" = "--inplace" ] ; then
  echo "Usage: $0 [[-]-inplace]. Provided input: $0 $@"
  exit 22
fi

if [ "$#" -ge 1 ] && [ "$#" -a "$1" = "-inplace" -o "$1" = "--inplace" ] && [ -e site/ ] ; then #sometimes disable clean runs, for development testing purposes
  echo "I see --inplace has been passed, and the dir exists, so I won't copy the new dir in again."
else
  rm -r -f site/ #make sure we have a clean slate
  cp -r ../mirror/ site/ # This step might take about a minute cold (on a HDD; on an SSD it should be shorter), but it's important to make sure we don't mess up the mirror by accident.
fi
main_site_dir='site/www.terrorisland.net'

ebook-convert --version || sudo apt install -y calibre #here I try to install ebook-convert if you don't have it. I only really try for ubuntu, however.

image_to_page () {
  a=${1#./cast}
  b=${a%.jpg}
  c=${b/%b/%20(alt)}
  echo "<html>
  <head></head>
  <body>
    <h1>$c</h1>
    <img src=\"$1\">
  </body></html>" >"$c.html"
}

echo 'Making Foreword into an "open ebook" with ebook-convert and then stealing the file...'
  ebook-convert foreword.md tmp-foreword --title "Foreword" >/dev/null
  cp tmp-foreword/index.html $main_site_dir/2-foreword.md.html
rm -r -f tmp-foreword/

echo 'Making Buzzsaw Review into an "open ebook" with ebook-convert and then stealing the files...'
  ebook-convert $main_site_dir/etcetera/buzzsaw_review.pdf tmp-review --title "Buzzsaw Review" >/dev/null #make it into an "open ebook" with ebook-convert and then steal the files
  cp tmp-review/index.html $main_site_dir/3-buzzsaw_review.pdf.html
  cp tmp-review/index-1_1.jpg $main_site_dir/
rm -r -f tmp-review/

cp title_page.html $main_site_dir/1-title_page.html
cp cover_back.html $main_site_dir/Z-cover_back.html
cp cover_back.pdn.png $main_site_dir/
[ -e $main_site_dir/strips/index.html ] && mv $main_site_dir/strips/index.html $main_site_dir/strips/000-index.html # This is the strip index, the incomplete "Year One Archives"; not to be confused with the website index, which is just the home page.
rm -f $main_site_dir/index.html # This deliberately deletes the old website index.html, as it's just the final strip, anyway. (And therefore the resulting book from it is jus a useless first page, frontmatter, and random strips you can reach from this first starting point.

cd $main_site_dir/images/misc
  for i in cast*.jpg
    do echo "BLAHHHHHH $i"; image_to_page "$i" ; done
cd -

cd $main_site_dir/
  shopt -s globstar
  echo >0-index.html
  for i in **/*.html ; do #will probably move this back to a for loop over the find output
    echo "<a href=\"$i\">`basename -s .html \"$i\"`</a>" >>0-index.html
  done
cd -

typeset_book () {
  # $1: file extension for desired file type, including the leading . (empty by default, which makes an OEB, mostly useful for debug)
  # $2: additional ebook-convert options to pass in at the end to facilitate your chosen format.
  echo "Making ebook with following extension: ${1:-}"
  ebook-convert $main_site_dir/0-index.html books/terror_island_unofficial-wyattscarpenter-2024"${1:-}" \
    --no-chapters-in-toc --max-toc-links 0 --breadth-first --max-levels 1 --toc-threshold 1 \
    --search-replace replacements.txt \
    --language en --cover cover.pdn.png \
    --authors "Ben Heaton&Lewis Powell" --book-producer "Wyatt S Carpenter" --pubdate 2024 --title "Terror Island" --rating 5 \
    --base-font-size 10 --smarten-punctuation --extra-css "* {box-sizing: border-box; font-size: normal;} p { text-indent: 1.5em; margin: 0em !important; padding-left: 0em !important; } h4 {margin-bottom: 0em; margin-top: 0.3em;} body {margin-left: 0em; margin-right: 0em;} div.title /* this is just styling from the original page that we wiped out by removing the CSS, and want to get back. */ { background:#eeeeee; color:#000000; padding:2px; border-left:15px solid #333333; border-bottom:1px solid #333333; font-size:small; font-weight:bold; } /*here we unsuccessfully try to correct nonsense it otherwise does*/ .calibre1 {margin: 0em !important} .strip1 {padding: 0em !important}" \
    ${2:-} #&>/dev/null #you can use this to quiet the diagnostic messages if you like.
}

#typeset_book ".pdf" '--custom-size 5.245x8.5 --pdf-page-margin-bottom 0 --pdf-page-margin-left 0 --pdf-page-margin-right 0 --pdf-page-margin-top 0 --margin-bottom 0 --margin-top 0 --margin-left 0 --margin-right 0' & # pdf options #interestingly, --pdf-footer-template <center>_PAGENUM_</center> gets an out-of-range error (calibre 6.11) #--paper-size a5 is closest to US trade paperback (6x9in) of the default options, but none are close enough, nor close enough to what we want...
typeset_book ".pdf" '--custom-size	5.245x8.5	--pdf-page-margin-bottom	0	--pdf-page-margin-left	0	--pdf-page-margin-right	0	--pdf-page-margin-top	0	--margin-bottom	0	--margin-top	0	--margin-left	0	--margin-right	0' & #because I had to reconfigure IFS above, the last string has tabs instead of spaces # pdf options #interestingly, --pdf-footer-template <center>_PAGENUM_</center> gets an out-of-range error (calibre 6.11) #--paper-size a5 is closest to US trade paperback (6x9in) of the default options, but none are close enough, nor close enough to what we want...

rm -r -f books/terror_island_unofficial-wyattscarpenter-2024  #make sure we have a clean slate for this
typeset_book & # This will create the OEB format
wait

#disable only for development purposes, sometimes
if [ "${1:-}" = "-inplace" -o "${1:-}" = "--inplace" ] ; then
  echo "I see --inplace has been passed, so I won't remove the content dir to clean up."
else
  rm -r site/
fi
