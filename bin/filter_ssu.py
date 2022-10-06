#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import argparse


def filter(args):
    """filter blast hits from refinem

    Args:
        args (obj): arguments from argparse
    """
    with open(args.ssu, "r") as i, open(args.output, "w") as o:
        header = i.readline()
        for line in i:
            splitted_line = line.split()
            evalue = splitted_line[7]
            align_length = splitted_line[8]
            percent_ident = splitted_line[9]

            if int(evalue) <= args.evalue:
                o.write(line)
            else:
                continue


def main():
    parser = argparse.ArgumentParser(prog="filter_ssu.py", usage="filter ssu hits from refinem")
    parser.add_argument("--evalue", help="evalue threshold")
    parser.add_argument("ssu", metavar="ssu.tsv", help="ssu tsv file generated by refinem")
    parser.add_argument("output", metavar="output.tsv", default="output.tsv", help="output file name")
    parser.set_defaults(func=filter)
    args = parser.parse_args()

    try:
        args.func(args)
    except AttributeError as e:
        parser.print_help()
        raise


if __name__ == "__main__":
    main()
