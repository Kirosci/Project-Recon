dir=$1
cd $dir
rm ssrf.txt 2> /dev/null

file="urls.txt"

cat $file | grep = | kxss | grep ">\|<" | tee kxss.txt