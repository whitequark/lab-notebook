---
kind: article
created_at: 2016-08-24 12:48:17 +0000
title: "Archiving cryptographic secrets on paper"
tags:
  - software
---

For storing rarely used secrets that should not be kept on a networked computer, it is convenient
to print them on paper. However, ordinary barcodes can store not much more than 2000 octets
of data, and in practice even such small amounts cannot be reliably read by widely used software
(e.g. [ZXing](https://github.com/zxing/zxing)).

In this note I show a script for splitting small amounts of data across multiple barcodes
and generating a printable document. Specifically, this script is limited to less than
7650 alphanumeric characters, such as from the [Base-64][rfc4648] alphabet. It can be used
for archiving Tarsnap keys, GPG keys, SSH keys, etc.

The script is implemented in Python, since this is one of the most widespread interpreters,
is compatible with both Python 2 and Python 3, and has one external dependency, the
[iec16022][] binary. On Debian-based systems these can be installed using
`apt-get install python3 iec16022`.

The script accepts any ASCII sequence and generates an HTML page sized adequately for printing
on A5 paper that contains multiple [ISO/IEC 16022][iso16022] (Data Matrix) barcodes.
The barcodes can be read with any off-the-shelf software, e.g. ZXing. Even if up to 30%
of the barcode area is corrupted, the data can still be recovered.

[iso16022]: http://www.iso.org/iso/catalogue_detail.htm?csnumber=44230

**Warning:** versions of iec16022 prior to 0.2.7 are likely to randomly drop characters
at the end of the barcode. **Every time** you are using this tool, check that the key is
actually recoverable before irreversibly erasing it.

[rfc4648]: https://tools.ietf.org/html/rfc4648
[iec16022]: https://github.com/rdoeffinger/iec16022

<%= highlight_code 'python', '/files/multi_iec16022.py' %>

It can be invoked as follows:

<% highlight_code 'shell' do %>
$ python multi_iec16022.py tarsnap.key tarsnap_datamatrix "Tarsnap key for foobar.com"
<% end %>

Afterwards, `tarsnap_datamatrix/index.html` will contain a page similar to the following:

<iframe src="/files/tarsnap-datamatrix-example/index.html"
        style="width: 100%; max-width: 148mm; height: 215mm;">
</iframe>

This page can now be printed on a laser printer (with no margins) and laminated.
If done properly, it is likely to outlast the service for which it holds the secrets.

Note that ZXing works most reliably when the types of barcodes are restricted to DataMatrix alone,
and also it has both a maximum distance to symbol (where the data is no longer recoverable)
as well as a minimum distance to symbol (where the symbol takes too much area of the camera,
confusing the pattern recognizer).

The ISO/IEC 16022 format was chosen because it is widely supported and admits a flexible
character set (e.g. the grammar of alphanumeric QR codes does not include lowercase letters).
However, no extensive thought was put into this choice and it is possible that another 2D barcode
would be more efficient.
