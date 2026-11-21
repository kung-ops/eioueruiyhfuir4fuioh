#!/usr/bin/env python3
"""Generate original 512x512 RGBA homebrew menu icon using standard library."""
import os,struct,sys,zlib
w=h=512
rows=[]
for y in range(h):
    row=bytearray()
    for x in range(w):
        grid=(x//64+y//64)%2
        r,g,b=(21,35,61) if not grid else (27,48,76)
        if 90<x<422 and 90<y<422 and (x<112 or x>400 or y<112 or y>400):r,g,b=(70,220,195)
        if 180<x<332 and 180<y<332:r,g,b=(79,176,245)
        row.extend((r,g,b,255))
    rows.append(b'\x00'+row)
def chunk(tag,data):
    return struct.pack('>I',len(data))+tag+data+struct.pack('>I',zlib.crc32(tag+data)&0xffffffff)
png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b''.join(rows),9))+chunk(b'IEND',b'')
path=sys.argv[1]
os.makedirs(os.path.dirname(path),exist_ok=True)
open(path,'wb').write(png)
