#!/bin/bash

# ================================================================================
# by Noah Huetter <noahhuetter@gmail.com>
# ================================================================================
#
# Copies the vivado block design export to a block_design.tcl used for make flow.
# Copies content between line 'current_bd_instance $parentObj' and
# '# Restore current instance' form input file to output file
#
# ================================================================================

sc=$1
bd=$2
if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo "Usage:"
  echo "  ./scripts/copy_bd.sh [bd_export] [block_design]"
  echo "For Example:"
  echo "  ./scripts/copy_bd.sh [build/projects/system.tcl] [projects/test/block_design.tcl]"
  exit;
fi

# Copy backup
cp $bd $bd.bak

# get total number of input lines
lines=`wc -l < $sc | tr -d '[:space:]'`

# get start line by searching for line "current_bd_instance $parentObj"
start=`grep -Fn 'current_bd_instance $parentObj' $sc | cut -f1 -d":"`
start=$((start+1))

# get end line by searching for line "# Restore current instance"
end=`grep -Fn '# Restore current instance' $sc | cut -f1 -d":"`
end=$((end-1))

# Check values
if [ "$start" -eq "0" ] || [ "$end" -eq "0" ]; then
   echo "Start or End line not found. Aborting.";
   exit;
fi

# Check values
if [ "$start" -gt "$end" ]; then
   echo "Start line is greater than end line. Aborting.";
   exit;
fi

# Print cut file
echo "Copying from line $start to line $end"
echo "Source: $sc"
echo "Target: $bd"

echo "# Copied form Vivado block design export" > $bd
cat $sc | tail -n -$((lines-start)) | head -n $((end-start)) >> $bd

# Done
echo "Done. Deleting Backup."
rm $bd.bak
