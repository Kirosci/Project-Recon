read domain
dir=$(head -1 $domain)
cd $dir
rm ssrf.txt 2> /dev/null

file="urls.txt"

cat $file | grep = | kxss | grep ">\|<" | tee kxss.txt