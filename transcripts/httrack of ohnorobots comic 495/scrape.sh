# This is the command I used, although it requires a little more manual clean up to get to the state in the repo.
# Also, I don't recommend running this command again, because I don't think the ohnorobot transcripts are going to change, so what's the point?

# This mirrors the search result pages
httrack -N '%[page].html' 'https://www.ohnorobot.com/index.php?self=1&page=0&s=.&comic=495'  -%v -O './h'

# This cats the relevant content
perl -0777 -ne 'while (/<ul\b[^>]*>(.*?)<\/ul>/sg) { print "$1\n" }' ?.html ??.html >catted.html

# I then manually rename catted.html to ../index.html
# I then manually save it to txt in firefox to produce index.txt — although that process leaves the spacing rather incorrect.
