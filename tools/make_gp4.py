#!/usr/bin/env python3
"""GP4 package project generator for exactly three app files."""
import argparse,datetime
from xml.sax.saxutils import quoteattr
p=argparse.ArgumentParser()
p.add_argument('--out',required=True)
p.add_argument('--content-id',required=True)
p.add_argument('files',nargs='+')
a=p.parse_args()
assert set(a.files)=={'eboot.bin','sce_sys/param.sfo','sce_sys/icon0.png'}
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
x=['<?xml version="1.0"?>',
'<psproject xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" fmt="gp4" version="1000">',
'<volume><volume_type>pkg_ps4_app</volume_type><volume_id>PS4VOLUME</volume_id><volume_ts>'+stamp+'</volume_ts>',
'<package content_id='+quoteattr(a.content_id)+' passcode="00000000000000000000000000000000" storage_type="digital50" app_type="full" />',
'<chunk_info chunk_count="1" scenario_count="1"><chunks><chunk id="0" layer_no="0" label="Chunk #0" /></chunks><scenarios default_id="0"><scenario id="0" type="sp" initial_chunk_count="1" label="Scenario #0">0</scenario></scenarios></chunk_info></volume>',
'<files img_no="0">']
for f in a.files:x.append('<file targ_path='+quoteattr(f)+' orig_path='+quoteattr(f)+' />')
x+=['</files><rootdir><dir targ_name="sce_sys" /></rootdir></psproject>']
open(a.out,'w').write('\n'.join(x)+'\n')
