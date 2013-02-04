#!/bin/sh

URL="http://kcwu.csie.org/~kcwu/tmp/moedict/development.sqlite3.bz2"
curl ${URL} > tmp.bz2
bunzip2 tmp.bz2
mv tmp ./MOEDict/db.sqlite3
