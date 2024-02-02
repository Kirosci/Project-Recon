read domain
dir=$(head -1 "$domain")
cd "$dir" || exit 1
rm xss.txt 2> /dev/null
file="urls.txt"
cat "$file" | grep = | kxss | grep '>\|<\|"' > xss.txt

cd ../