## Update pipes: a tool for jenkins
## This will do a few things, based on options.
## First, read the pipename/ec list.  For each pipename:
## if backup id is provided, copy config.xml to config.backup.(id)
## then use sed to copy the template file to config.xml

helpFunction()
{
   echo ""
   echo "Usage: $0 -p pipefile -parameterA -b backup -t template -j jobsfolder"
   echo -e "\t-p filename of a text file with pipename (space) EC#"
   echo -e "\t-b backup id: copy current config to config.id"
   echo -e "\t-t template: name of file containing replaceable values: {{1}} and {{2}}"
   echo -e "\t-j jobs folder: path to the top-level jobs folder (no trailing /)"
   exit 1 # Exit script after printing help
}

while getopts "p:b:t:j:" opt
do
   case "$opt" in
      p ) pipefile="$OPTARG" ;;
      b ) backupid="$OPTARG" ;;
	  t ) template="$OPTARG" ;;
	  j ) jobsfolder="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


while IFS= read -r line; do
    if [[ "$line" != '#'* ]]; then
		pipeid=$(echo "$line" | cut -f1 -d ' ')
		ecid=$(echo "$line" | cut -f2 -d ' ')

		echo "Working on $pipeid for EC $ecid"
		if [[ -n $backupid ]]; then
			echo "making backup"
			cp "$jobsfolder/$pipeid/config.xml" "$jobsfolder/$pipeid/config.backup.$backupid"
		fi
		sed -e "s/{{1}}/$pipeid/" -e "s/{{2}}/$ecid/" "$template" > "$jobsfolder/$pipeid/config.xml"

		echo "=================================="
	fi
done < "$pipefile"
