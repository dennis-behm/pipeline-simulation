#!/bin/bash

# Set the source and destination directories
SEARCH_ROOT="../."
DESTINATION_FOLDER="evidences"
rc=0

wdEvidencesIndex="reporting_index"
wdEvidencesRoot="${DESTINATION_FOLDER}"

# Re-Create the destination directory
rm -Rf "$DESTINATION_FOLDER"
mkdir -p "$DESTINATION_FOLDER"

echo " "
echo "Copy all evidences from documentation"
echo "*******************************************"
# Preserve evidences of each deployment process

# Find and process each evidence.yaml file
find "${SEARCH_ROOT}" -type f -name "evidence.yaml" | while read -r file; do
    # Get the directory of the file and build the destination path
    relative_path="${file#$SEARCH_ROOT/}"

    # Determine the destination path (preserving directory structure)
    dest_path="$DESTINATION_FOLDER/$(dirname "$relative_path")"

    # Create destination subdirectory if it doesn't exist
    mkdir -p "$dest_path"

    # Copy the file
    cp "$file" "$dest_path/"
    rc=$?
    echo "Copied: $file -> $dest_path/"
done

echo " "
echo "Refresh Wazi Deploy index for all applications"
echo "*******************************************"

CMD="wazideploy-evidence  --indexFolder $wdEvidencesIndex --dataFolder $wdEvidencesRoot i"
echo "[INFO] Executing following command to build WD index: $CMD"
${CMD}
rc=$?

# Error Handling
if [ $rc -eq 0 ]; then
    echo "[INFO] - Query Wazi Deploy index completed. Continue with rs2 to run queries against index."
else
    echo "[WARNING] - Query Wazi Deploy index failed."
    exit 1
fi
