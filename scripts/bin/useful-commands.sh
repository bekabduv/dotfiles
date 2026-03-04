echo "THIS FILE IS NOT SUPPOSED TO BE EXECUTED"
exit 0

# This copies pc's own ip address to system clipboard
hostname -I | awk '{print $1}' | xsel --clipboard --input

# Expose you localhost on the network when using vite
# The -- before --host ensures the flag is passed as an argument
# to the Vite command itself, not npm
npm run dev -- --host
# Also make run these if you have problems with firewall when using vite
sudo firewall-cmd --permanent --add-port=3000-9000/tcp # --zone=public is automatically iferred
sudo firewall-cmd --reload

# Rename files in a directory
i=((0));
for file in path/to/dir/*; do
  mv "$file" "file$i";
  i=((i+1));
done;

# Create a boilerplate like importing components automatically
# Components should have the same name as the filename
# DIR is the directory from where to import files
DIR=src/components
for file in "$DIR/"*; do
  BASENAME="$(basename "$file")"
  COMPONENT="${BASENAME%.*}"
  echo "import $COMPONENT from \"$DIR/$COMPONENT\"" >> src/components/Demo.tsx
done

# Make a template or boilerplate
# Create a boilerplate json file or some other kind
i=$((0));
echo "[" >> src/data/items.json
for photo in public/*; do
  echo "{
    \"id\": $i,
    \"name\": \"photo$i\",
    \"price\": 10,
    \"url\": \"photo$i.jpg\"
  }," >> src/data/items.json
i=$((i+1));
done;
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

# Store filenames in an array
files=()
for file in src/Components/*; do
  files+=("$(basename "$file")")
done;

# Bulk raname files in a directory
count=$((0))
for file in public/*; do
  mv "$file" "file$count.jpg" # a8da87akjda8ad8haa.jpg -> file1.jpg ...
  count=$((count+1))
done;

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

# Add/Insert a text into a line of a file (e.g. line 5)
sed -i "5i$someText" path/to/file

# Prepend to a file
# This checks first if the line already exists
grep -qxF '@import "tailwindcss";' src/index.css || \
{ echo '@import "tailwindcss";'; cat src/index.css; } > tmp && mv tmp src/index.css

# Trash files/dirs instead of deleting permanently
trash file.txt

# Linux dirsto detection
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  echo "$NAME"
elif command -v lsb_release >/dev/null 2>&1; then
  lsb_release -si
elif [[ -f /etc/redhat-release ]]; then
  cat /etc/redhat-release
else
  echo "Unknown Linux distribution"
fi
