#!/usr/bin/env python3

# Include standard modules
import argparse

# # Initiate the parser with a description
parser = argparse.ArgumentParser(
    description='outputs user name and home dir for given uid')

# Add the arguments
parser.add_argument('--uid',
                    metavar='uid',
                    type=str,
                    help='uid of the user')

# Execute the parse_args() method
args = parser.parse_args()

# Check for --uid
if args.uid:
    with open("/etc/passwd") as file_in:
        # read the file line by line
        for line in file_in:
            split = []
            split.append(line.split(":"))
            # uid is the third element
            if split[0][2] == args.uid:
                print("USER_NAME={}".format(split[0][0]))
                print("HOME_DIR={}".format(split[0][5]))
                break
