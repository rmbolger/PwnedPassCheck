#!/usr/bin/env python3

"""split-pwned-passwords.py
Splits the extracted pwned passwords file (sorted by hash) into
hash prefix files (first 5 characters) the same way the Pwned
Passwords API does
https://haveibeenpwned.com/API/v3#PwnedPasswords
"""

import argparse
import os

def main(file, outputFolder="./range"):
    """splits the file into 5 char hash prefix files."""

    # create the output folder if it doesn't exist
    if not os.path.exists(outputFolder):
        print("Creating output folder")
        os.makedirs(outputFolder)

    # loop through the file
    lastPrefix = ""
    curContents = ""
    with open(file, "r") as ifile:
        for line in ifile:

            if len(line) < 33:
                continue

            # split into prefix/suffix
            prefix = line[0:5]
            suffix = line[5:]

            # check if new prefix
            if prefix != lastPrefix:

                # write out previous file
                if curContents != "":
                    with open(outputFolder + "/" + lastPrefix, "w") as splitFile:
                        print(curContents.strip(), file=splitFile)

                # start buffering next file
                print(prefix)
                curContents = suffix
            else:
                # add to next file buffer
                curContents += suffix

            # update last prefix
            lastPrefix = prefix

    # write out last file
    with open(outputFolder + "/" + prefix, "w") as splitFile:
        print(curContents.strip(), file=splitFile)
    print(prefix)

    ifile.close()



def _cli():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        argument_default=argparse.SUPPRESS)
    parser.add_argument('-f', '--file', help="The HIBP pwned passwords file *ordered by hash*")
    parser.add_argument('-o', '--outputFolder', help="The output folder the split files should be written to")
    args = parser.parse_args()
    return vars(args)

if __name__ == '__main__':
    main(**_cli())
