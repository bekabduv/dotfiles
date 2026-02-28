# This copies pc's own ip address to system clipboard
hostname -I | awk '{print $1}' | xsel --clipboard --input

# Expose you localhost on the network when using vite
# The -- before --host ensures the flag is passed as an argument
# to the Vite command itself, not npm
npm run dev -- --host
# Also make run these if you have problems with firewall when using vite
sudo firewall-cmd --permanent --add-port=5173/tcp
sudo firewall-cmd --reload

# Rename files in a directory
i=((0))
for file in path/to/dir/*; do
  mv "$file" "file$i"
  i=((i+1))
done;

# Make a template or boilerplate
i=((0))
echo "[" >> src/data/items.json
for photo in public/*; do
  echo "{
  \"id\": $i,
  \"name\": \"\",
  \"price\": 10,
  \"url\": \"photo$i\"
}," >> src/data/items.json
  i=$((i+1))
done
echo "]" >> src/data/items.json;

# Get the names of the files in a directory
basename /path/to/file # basename automatically prints the basename of files
# examples:
for file in /path/to/dir/*; do
  echo "$(basename "$file")"
  # or simply:
  # basename "$file"
  # or even faster version
  # echo "${file##*/}"
done


# Remove extensions from files
filepath="example.txt"
filename="${filepath%.*}"

# Add/Append larger text/templates into files
cat <<EOF > somefile.txt
This
is
an
example
EOF
# EOF is known as heredoc
# Prints multiline text
cat <<EOF
Hello
World
EOF

# Prepend to a file
# This checks first if the line already exists
grep -qxF '@import "tailwindcss";' src/index.css || \
{ echo '@import "tailwindcss";'; cat src/index.css; } > tmp && mv tmp src/index.css
