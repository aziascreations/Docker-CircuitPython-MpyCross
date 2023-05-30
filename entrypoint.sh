#!/bin/sh

# Grabbing the extra mpy-cross args, and checking if we just want the help text
MPY_CROSS_EXTRA_ARGS="${MPY_CROSS_EXTRA_ARGS:-}"

if [[ "$MPY_CROSS_EXTRA_ARGS" == "-h" || "$MPY_CROSS_EXTRA_ARGS" == "--help" ]]; then
	mpy-cross --help
	exit 0
fi


echo "Grabbing PUID and PGID..."

PUID="${PUID:-0}"
PGID="${PGID:-0}"

is_numeric() {
	re='^[0-9]+$'
	if [[ $1 =~ $re ]]; then
		return 0
	else
		return 1
	fi
}

if ! is_numeric "$PUID"; then
	echo "> PUID is not a valid number or contains non-numeric characters !"
	exit 1
fi

# Check if PGID is numeric
if ! is_numeric "$PGID"; then
	echo "> PGID is not a valid number or contains non-numeric characters !"
	exit 2
fi

echo "> PUID:$PUID"
echo "> PGID:$PGID"


echo "Preparing directories..."

INPUT_DIR="/data/input/"
OUTPUT_DIR="/data/output/"

echo "> Creating $INPUT_DIR"
mkdir -p $INPUT_DIR

echo "> Creating $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR

echo "> Updating ownership"
chown $PUID:$PGID $INPUT_DIR
chown $PUID:$PGID $OUTPUT_DIR


echo "> Changing CWD to $INPUT_DIR"
cd $INPUT_DIR


echo "Converting files..."

find "$INPUT_DIR" -type f -name "*.py" -print0 | while IFS= read -r -d '' file; do
	relative_file="${file#$INPUT_DIR}"
	
	new_relative_file="${relative_file%.*}.mpy"
	
	output_path="${file//$INPUT_DIR/$OUTPUT_DIR}"
	
	output_file="${output_path//$relative_file/$new_relative_file}"
	
	# In case we have sub-folders, we create them.
	# No error will be raised by `mpy-cross` if it is missing sadly...
	mkdir -p "${output_file%/*}"
	chown $PUID:$PGID "${output_file%/*}"
	
	echo "> $file => $relative_file => $output_file"
	
	mpy-cross -o $output_file $MPY_CROSS_EXTRA_ARGS $relative_file
	chown $PUID:$PGID $output_file
done


echo "Done :)"
exit 0
