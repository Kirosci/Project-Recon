read domain
dir=$(head -1 "$domain")
cd "$dir" || exit 1
file="urls.txt"
cat "$file" | grep = | kxss | grep '>\|<\|"' | tee kxss.txt