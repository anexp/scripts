#!/bin/sh


archwiki_keys() {

xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'

}

archwiki_keys
