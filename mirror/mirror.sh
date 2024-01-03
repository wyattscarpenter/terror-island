#For testing purposes, you may pass this script an argument for which step to start at. 1 to run every step, 2 to skip the first step, 3 to skip the first two steps. 4 or above to exit immediately (there are only 3 steps).

if [ "${1:-0}" -le 1 ] ; then
  echo 'Step 1: This line does a basic pass to get all of the webpages we need. If need be, you can also just run this line and get a pretty good result (there is no way to do that using this script; Im just saying you can run it on your own).'
  wget -erobots=off --mirror --convert-links --adjust-extension --page-requisites --span-hosts --domains=terrorisland.net,www.terrorisland.net http://www.terrorisland.net http://terrorisland.net # Note that you canNOT just use terrorisland.net, you have to include the www, because all the links in the html point to the www version. Also, you have to ignore the robots.txt, because the webserver doesn't have one.
fi

if [ "${1:-0}" -le 2 ] ; then
  echo 'Step 2: Getting the prereq from the "other domain" terrorisland.net was very easy, but for the rest of the internet we need to do it sort of "manually". We do this by downloading all the files again. This is bad, because wget should just have been able to do this all in one sweep. But it is only O(2n) bad, so, you know...'
  wget -p --convert-links --span-hosts `find www.terrorisland.net/` #the link-rewriting is wrong unless we use wget on everything at once, therefore we do it this way/ That is, if we did it a different way, then 
fi

findreplace () {
  # $1: string to grep for. Minimally-quoted, just for shell.
  # $2: string to sed interpret. Maximally-quoted, as it must be interpreted as a regex (and also as a shell variable twice? Does that happen? If so, can I get around it with ${x@Q}?)
  # $3: string to sed replace in. Medium-quoted, as there are fewer special meanings in this half of a regex replacement statement.
  # See below for example usages of these
  
  #The */* means it explicitly does not match stuff in the root directory, which is good because otherwise it would replace the text in this very script. It hits every other directory, though.
  grep -rliI $1 */* | xargs -i@ sed -i 's/'$2'/'$3'/g' @
  # The grep is, like, recursive, only report file names of matches, case insensitive, and ignore binary files, in that order, iirc.
}

if [ "${1:-0}" -le 3 ] ; then
  echo 'Step 3: Handle the files we need to grab especially because the websites are down.'
  findreplace 'http://waxintellectual.com/images/buttons/affiliation/factions/' 'http\:\/\/waxintellectual\.com\/images\/buttons\/affiliation\/factions\/' '..\/..\/waxintellectual\.com\/images\/buttons\/affiliation\/factions\/'
  findreplace 'http://www.merehappenings.com/images/MH_title.gif' 'http\:\/\/www\.merehappenings\.com\/images\/MH_title\.gif' '..\/..\/www.merehappenings\.com\/images\/MH_title.gif'
  findreplace 'http://www.webcomicbattle.com/images/comicbutton.gif' 'http\:\/\/www\.webcomicbattle\.com\/images\/comicbutton\.gif' '..\/..\/www.webcomicbattle.com\/images\/comicbutton.gif'
  findreplace 'http://www.photowebcomics.com/button.php?u=Factitious' 'http\:\/\/www\.photowebcomics\.com\/button\.php?u=Factitious' '..\/..\/www.photowebcomics.com\/images\/vote.jpg'
  sed -i 's/..\/..\/www.photowebcomics.com\/images\/vote.jpg/..\/www.photowebcomics.com\/images\/vote.jpg/g' 'www.terrorisland.net/etc.html'
fi
#the special directories are:
# waxintellectual.com/
#   (eg https://web.archive.org/web/20170926140438/http://waxintellectual.com/images/buttons/affiliation/factions/a-siddite-1.jpg )
# www.merehappenings.com/
#   https://web.archive.org/web/20110129082018/http://www.merehappenings.com/images/MH_title.gif
# www.webcomicbattle.com/
#   https://web.archive.org/web/20060718033636/http://www.webcomicbattle.com/images/comicbutton.gif
# www.photowebcomics.com/ 
#   www.photowebcomics.com/button.php?u=Factitious, which probably linked to images/vote.jpg at the time it was posted (so I have rewritten it to point it to there), and later linked to 4.jpg. I assume (I know it's been both at times in the past, but it's not really clear when is when).
