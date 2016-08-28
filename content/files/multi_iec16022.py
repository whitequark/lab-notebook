#!/usr/bin/env python3
# encoding:utf-8

# This code is released under CC0.
# https://creativecommons.org/publicdomain/zero/1.0/

import argparse, re, os, subprocess, hashlib

parser = argparse.ArgumentParser(description='Convert ASCII data to printable A5 HTML page.')
parser.add_argument('input', metavar='INPUT', type=argparse.FileType('r'),
                    help='input tarsnap.key file')
parser.add_argument('output', metavar='OUTPUT', type=str,
                    help='output directory with HTML and DataMatrix images')
parser.add_argument('title', metavar='TITLE', type=str,
                    help='title for the output page')
args = parser.parse_args()

key = args.input.read()
os.mkdir(args.output, 0o700)

chunks = re.findall(re.compile('.{1,850}', re.DOTALL), key)
for index, chunk in enumerate(chunks):
    subprocess.call([
        "iec16022", "--ecc=200", "--format=PNG",
        "--barcode={}".format(chunk),
        "--outfile={}/chunk{}.png".format(args.output, index)
    ])

with open("{}/index.html".format(args.output), "w") as html:
    images = ""
    for index, chunk in enumerate(chunks):
        images += """<img src="chunk{}.png">""".format(index)
    digest = hashlib.sha256(key.encode()).hexdigest()
    html.write("""<!DOCTYPE html>
<head>
    <style type="text/css">
    * {{ margin: 0; padding: 0; }}
    body {{ width: 128mm; height: 190mm;
            margin: 10mm; padding: 1mm;
            border: 1px solid black;
            font-size: 14px; }}
    p {{ padding-top: 1em; }}
    img {{ width: 41mm; height: 41mm;
           image-rendering: pixelated; }}
    </style>
</head>
<body>
    <p>This page contains {}.</p>
    <p>This data is encoded using multiple ISO/IEC 16022:2006
    (Data&nbsp;Matrix) ECC 200 barcodes.
    To reproduce the data, scan every barcode from left to right
    and from top to bottom, and concatenate their contents without
    anything in between.</p>
    <p>The SHA-256 digest of the original data is <small>{}</small>.</p>

    <p>{}</p>
</body>
""".format(args.title, digest, images))
