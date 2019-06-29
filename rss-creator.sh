#!/run/current-system/sw/bin/bash

get-newest-files ()
{
  dirpa="$1"
  if [[ -f "$dirpa/.files-before" ]];
  then
    diff <(find "$dirpa" -maxdepth 1 -not -type d -not -path '*/\.*' ! -name index.html ! -name style.css) "$dirpa/.files-before" | grep '^< ' | sed 's/< //'
  else
    find "$dirpa" -maxdepth 1 -not -type d -not -path '*/\.*' ! -name index.html ! -name style.css
  fi

  find "$dirpa" -maxdepth 1 -not -type d -not -path '*/\.*' ! -name index.html ! -name style.css > "$dirpa/.files-before"
}

content-into-rss-xml ()
{
  SourceFile="$1"
  rssFile="$2"

  #echo "SourceFile is $1"

  title=`xmllint --html --xpath '/html/body/title/text()' "$SourceFile" 2>/dev/null`
  body=`xmllint --html --xpath '/html/body/article' "$SourceFile" 2>/dev/null` 
  date=`xmllint --html --xpath '/html/body/p/text()' "$SourceFile" 2>/dev/null`

  guid="https://www.resonyze.xyz/${SourceFile#/home/vector/website/html/}"

  set +H

  printf "\\n<item>\\n<title>%s</title>\\n<guid>%s</guid>\\n<link>%s</link>\\n<pubDate>%s</pubDate>\\n<description><![CDATA[\\n%s\\n]]></description>\\n</item>\\n\\n" "$title" "$guid"   "$guid" "$date" "$body" > /tmp/article-body

  sed -i '/<!-- LB -->/r /tmp/article-body' "$rssFile"
}

get-sub-dirs ()
{
   find "$1" -type d | grep -v '/img' | grep -v '/res'
}

desDirs="$HOME/website/html/opinion\n$HOME/website/html/blog\n$HOME/website/html/web-notes"

rssFile="$HOME/website/html/rss.xml"

for cDir in `echo -e "$desDirs"`;
do
  for subDir in `get-sub-dirs "$cDir"`;
  do
    for newFile in `get-newest-files "$subDir"`;
    do
      content-into-rss-xml $newFile $rssFile
      #echo $newFile from "$subDir"
    done
  done
done
