#!/usr/bin/env python

# The contents of this file are subject to the MonetDB Public
# License Version 1.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.0.html
# 
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
# 
# The Original Code is the Monet Database System.
# 
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-2003 CWI.
# All Rights Reserved.
# 
# Contributor(s):
# 		Martin Kersten <Martin.Kersten@cwi.nl>
# 		Peter Boncz <Peter.Boncz@cwi.nl>
# 		Niels Nes <Niels.Nes@cwi.nl>
# 		Stefan Manegold  <Stefan.Manegold@cwi.nl>

import sys
import fileinput
import os

build=os.path.abspath(sys.argv[1]);
prefix=os.path.abspath(sys.argv[2]);

source=os.path.abspath(os.path.join(build,os.pardir))

subs = [
    ('@exec_prefix@',       prefix),
    ('@sysconfdir@',        r"${prefix}\etc"),
    ('@localstatedir@',     r"${prefix}\var"),
    ('@libdir@',            r"${prefix}\lib"),
    ('@bindir@',            r"${prefix}\bin"),
    ('@mandir@',            r"${prefix}\man"),
    ('@includedir@',        r"${prefix}\include"),
    ('@datadir@',           r"${prefix}\share"),
    ('@infodir@',           r"${prefix}\info"),
    ('@libexecdir@',        r"${prefix}\libexec"),
    ('@PACKAGE@',           r"MonetDB"),
    ('@VERSION@',           r"4.3.15"),
    ('@DIRSEP@',            "\\"),
    ('@prefix@',            prefix),
    ('@MONET_BUILD@',       build),
    ('@MONET_SOURCE@',      source),
]

for key, val in subs[:]:
    subs.insert(0, ('@Q'+key[1:], val.replace('\\', r'\\')))


def substitute(line):
    for (p,v) in subs:
        line = line.replace(p, v);
    return line

for line in fileinput.input(sys.argv[3:]):
    sys.stdout.write(substitute(line))
