# Faktur

A simple tool to timestamp data and relay them to somewhere.

Smart contract component.


Donation:

**BTC**: 1MYiMU3GfsgEP4EYHHonG9Fy6DkA1JC3B5

**ETH**: 0xc8f8371BDd6FB64388F0D65F43A0040926Ee38be

## Description

When new a new files on backend appears:
 1. A pre-receipt is created
 2. The file is sent to delivrery
 3. The file to files queue

When time is due:
 1. Anchor every files in queue
 2. Publish new receipts
 3. Send result with alert

## Receipt

The pre-receipt emission open a challenge period based on the Smart Contract SLA(TODO).
The client should check the validity of the receipt (Smart Contract funcion)

The pre-receipt can't be challenged for N period.

After N period, the pre-receipt if submitted on-chain can
open a challenge for the oracle to prove that it timestamped the hash
correctly.

To cancel the challenge the oracle submit the audit path on-chain, keeping the funds if provided.

After N+X period, the pre-receipt won't be challengeable anymore and is put to removal.

Verify by calling either VerifyRFC6962 or VerifyMerkleHash Smart Contract audit function.

## Verification algorithm

 - [x] [rfc6962](https://tools.ietf.org/html/rfc6962#section-2.1.1) "Certificate transparency"
 - [x] [Merkle Tree](https://github.com/chainpoint/whitepaper/blob/master/chainpoint_white_paper.pdf) (Chainpoint 2.1, deprecated)
