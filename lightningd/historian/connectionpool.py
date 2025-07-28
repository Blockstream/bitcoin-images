#!/usr/bin/env python3
from pyln.client import Plugin
from threading import Thread
import urllib3
import json
import time

plugin = Plugin()

def maintain():
    target = 100
    while True:
        print("Checking connection pool")
        peers = plugin.rpc.listpeers()
        print(peers)
        p = urllib3.request('GET', 'https://1ml.com/node?active=true&public=true&json=true&order=lastupdated')
        t = json.loads(p.data)
        p = [n for n in t if 'addresses' in n and 'onion' not in n['addresses'][0]['addr']]
        print(p)

        candidates = [(n['pub_key'], n['addresses'][0]['addr']) for n in p]
        print(candidates)
        numcandidates = target - len(peers['peers'])
        candidates = candidates[:numcandidates]
        print(candidates)

        for c in candidates:
            try:
                plugin.rpc.connect(c[0], c[1])
            except:
                pass
        
        time.sleep(10)
    

@plugin.init()
def init(options, configuration):
    print(options, configuration)
    t = Thread(target=maintain, daemon=True)
    t.start()


plugin.run()
