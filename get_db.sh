#!/bin/sh

URL="http://kcwu.csie.org/~kcwu/moedict/dict-revised.sqlite3.bz2"
downloaded_file="dict-revised.sqlite3.bz2"

curl ${URL} > ${downloaded_file}

bzip2 -d ${downloaded_file}

# Convert image to unicode using moedict
curl -O https://raw.github.com/g0v/moedict-epub/master/sym.txt
curl -O https://raw.github.com/g0v/moedict-epub/master/db2unicode.pl

echo ""
echo "Convert image to unicode by moedict-epub "
perl db2unicode.pl | sqlite3 dict-revised.unicode.sqlite3  2>&1 > /dev/null

# create index
if [ -f dict-revised.unicode.sqlite3 ]; then
    echo "Create dict indices"
    sqlite3 dict-revised.unicode.sqlite3 'CREATE INDEX "index_entries_title" ON "entries" ("title")'

    rm -f sym.txt
    rm -f db2unicode.pl
	rm -f dict-revised.sqlite3*
    mv dict-revised.unicode.sqlite3 ./MOEDict/db.sqlite3
fi
