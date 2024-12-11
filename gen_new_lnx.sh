#!/bin/bash

# Display messages
echo "This tool will generate directories for Linux"
echo "Press enter to continue"
read -r  # Wait for user input

# Create the main directory
mkdir -p lnx
cd lnx || { echo "Failed to enter lnx directory"; exit 1; }

# Create subdirectories
mkdir -p bin etc lib mnt proc run srv tmp var dev home media opt root sbin sys usr

echo "Directories have been created successfully!"