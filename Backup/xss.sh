dir=$1
cd $dir

file="urls.txt"

cat $file | grep = | kxss | grep ">\|<" | tee kxss.txt