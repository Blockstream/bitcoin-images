### Dockerized hal
Use as:
```
$ docker run --rm blockstream/hal-docker hal address inspect tb1qcw5eh6kasd3ts2a2kzg5mal7yhft0nc0h48wjm
{
  "network": "testnet",
  "type": "p2wpkh",
  "script_pub_key": {
    "hex": "0014c3a99beadd8362b82baab0914df7fe25d2b7cf0f",
    "asm": "OP_0 OP_PUSHBYTES_20 c3a99beadd8362b82baab0914df7fe25d2b7cf0f"
  },
  "witness_program_version": 0,
  "witness_pubkey_hash": "c3a99beadd8362b82baab0914df7fe25d2b7cf0f"
}
```
