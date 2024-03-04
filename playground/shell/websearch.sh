#!/bin/bash

web="https://www.google.com.hk/search?q="

case $1 in
	-w)
		web="http://"
		shift
		;;
    -b)
		web="https://www.baidu.com/s?wd="
		shift
		;;
    -g)
		web="https://www.google.com.hk/search?q="
		shift
		;;
    -git)
		web="https://github.com/search?q="
		shift
		;;
    -npm)
		web="https://www.npmjs.com/search?q="
		shift
		;;
esac

searchWord=""
for item in "$@"
do
	if [[ "$item" != "-w" && "$item" != "-b" && "$item" != "-g" &&  "$item" != "-l" && "$item" != "-git" && "$item" != "-npm" ]]; then
		if [ -z "$searchWord" ]; then
			searchWord="$item"
		else
			searchWord="$searchWord $item"
		fi
	fi
done

echo "正在搜索：${web}${searchWord} ..."
xdg-open "${web}${searchWord}"
