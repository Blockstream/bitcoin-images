#!/usr/bin/env python3
from pyln.client import Plugin
from threading import Timer
import os
from concurrent.futures import ThreadPoolExecutor
import random
import requests

plugin = Plugin()


known_nodes = {
    '024a2e265cd66066b78a788ae615acdc84b5b0dec9efac36d7ac87513015eaf6ed': ('52.16.240.222', 9735),
    "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432": ("104.198.32.198", 9735),
    "039376f846cb4e137f3474baa7fbe74ec627745c7d5c54935b99fbb1b60a62c9b3": ("159.65.162.130", 9735),
    "02ad6fb8d693dc1e4569bcedefadf5f72a931ae027dc0f0c544b34c1c6f3b9a02b": ("167.99.50.31", 9735),
    "024bd94f0425590434538fd21d4e58982f7e9cfd8f339205a73deb9c0e0341f5bd": ("165.227.69.151", 9735),
    "03864ef025fde8fb587d989186ce6a4a186895ee44a926bfc370e2c366597a3f8f": ("34.239.230.56", 9735),
    "03cde60a6323f7122d5178255766e38114b4722ede08f7c9e0c5df9b912cc201d6": ("34.65.85.39", 9745),
    "033d8656219478701227199cbd6f670335c8d408a92ae88b962c49d4dc0e83e025": ("34.65.85.39", 9735),
    "030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f": ("52.50.244.44", 9735),
    "03abf6f44c355dec0d5aa155bdbdd6e0c8fefe318eff402de65c6eb2e1be55dc3e": ("18.221.23.28", 9735),
    "02ad6fb8d693dc1e4569bcedefadf5f72a931ae027dc0f0c544b34c1c6f3b9a02b": ("167.99.50.31", 9735),
    "0217890e3aad8d35bc054f43acc00084b25229ecff0ab68debd82883ad65ee8266": ("23.237.77.11", 9735),
}


desired_pool_size = 25
executor = ThreadPoolExecutor(max_workers=10)
interval = 180


def gather_candidates(num):
    known_keys = set([n[0] for n in known_nodes])
    if num < 1:
        return []

    if len(known_nodes) < 100:
        
        for n in plugin.rpc.listnodes()['nodes']:
            if n['nodeid'] in known_keys:
                continue
        
            if 'addresses' not in n or len(n['addresses']) < 1:
                continue
    
            addr = n['addresses'][0]
            if addr['type'] != 'ipv4':
                continue
            known_nodes[n['nodeid']] = (addr['address'], addr['port'])

    num = min(num, len(known_nodes))
    smpl = random.sample(known_nodes.items(), num)
    for k, v in smpl:
        del known_nodes[k]
    
    plugin.log("Returning {} nodes to connect to".format(num))
    return [(k, v[0], v[1]) for k, v in smpl]


def check_pool(plugin):
    plugin.log("Checking connection pool")

    peers = plugin.rpc.listpeers()['peers']
    plugin.log("Currently have {}/{} peers".format(
        len(peers),
        desired_pool_size
    ))

    if len(peers) < desired_pool_size:
        candidates = gather_candidates(desired_pool_size - len(peers))
        for c in candidates:
            executor.submit(plugin.rpc.connect, "{}@{}:{}".format(*c))

    # Schedule the next run
    Timer(interval, check_pool, [plugin]).start()


@plugin.init()
def on_init(plugin, **kwargs):
    nodes = requests.get('https://1ml.com/node?order=capacity&json=true').json()
    nodes = {n['pub_key']: n['addresses'][0]['addr'] for n in nodes}
    known_nodes.update(nodes)
    check_pool(plugin)


plugin.run()
