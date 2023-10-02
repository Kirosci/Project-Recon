read domain
dir=$(head -1 "$domain")
cd "$dir" || exit 1
file="testurls.txt"
cat "$file" | grep = | kxss | grep '>\|<\|"' | tee kxss.txt