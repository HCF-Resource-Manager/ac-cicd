directory="/var/lib/jenkins/jobs"

if [ ! -d "$directory" ]; then
    exit 1
fi

if [ -f "datalist.txt" ]; then
    rm "datalist.txt"
fi

# Loop through files in the target directory
for subdir in "$directory"/*; do
    if [ -d "$subdir" ]; then
	    # part1="$subfile" | cut -c23-
	    part1="$subdir"
	    echo "subdir is '$part1'"
	    
	    part1b="$subdir/config.xml"
	    echo "searchvalue (part1b) is '$part1b'"

	    if [ -f "$part1b" ]; then
		    echo "found a config"
	    else
		    echo "no config file - skipping"
		    continue
	    fi
	    d1=$(echo "$part1" | cut -c23-)

	    part2=$(<"$part1b")

	    d2=$(echo "$part2" | grep defaultValue | grep vmec | head -n1 | cut -c27-31)

 		echo "d1 is $d1 and d2 is $d2"

	if [ -z "$d2" ]; then
		echo "empty"
		continue
	fi

	    d3="$d1 "
	    d3+="$d2"
	    echo "d3 is $d3"
	    echo "$d3" >> datalist.txt
    fi
done
