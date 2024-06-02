#!/bin/bash

# Define variables
SCRAPING_SCRIPT="./datascrape.py"
MODEL_SCRIPT="model.py"
GENERATED_JSON="newminer.json"

echo "Please enter your miner ID:"
read address

echo "Please enter your loan amount:"
read loan

# Function to print green commands
print_green_command() {
    echo -e "\033[32m$1\033[0m"  # \033[32m for green color, \033[0m to reset the color
}

# Step 1: Run the script to get the onchain data
echo
echo "Running script to get the onchain data..."
python3 $SCRAPING_SCRIPT $address

# Check if newminer.json is generated
if [ ! -f "$GENERATED_JSON" ]; then
    echo "Scraping failed: $GENERATED_JSON not found."
    exit 1
fi
print_green_command "Data fetched successfully for $address."

echo 
modified_json=$(jq --arg varName "LoanAmount" --arg varValue $loan '.[$varName] = $varValue' "$GENERATED_JSON" | jq -c .)
#print $modified_json
export WEB3_PRIVATE_KEY=

echo "Model is running on Lilypad..."
lilypad_output=$(lilypad run github.com/project-Fold/lilyconfig:v3.5 -i Prompt="$modified_json") 
echo "$lilypad_output"
print_green_command "Model ran sucessfully."
echo "Predicting Reputation Score and Calculating Collateral..."
# Use grep and awk to extract the file path for stdout
file_path=$(echo "$lilypad_output" | grep -o "/tmp/lilypad/data/downloaded-files/[^ ]*/stdout")

# Check if the file path is extracted
if [ -z "$file_path" ]; then
    echo "Error: File path not found in the command output."
    exit 1
fi

echo "Predicting Reputation Score and Calculating Collateral..."
# Display the contents of the extracted file path
cat "$file_path"

# End of script
print_green_command "Prediction done successfully."
