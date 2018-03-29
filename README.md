# Faktur

A simple tool to record the existence and relay them to somewhere

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

Verify mecanism:
 1. Verify by calling smart contract
 2. If callback is non-null, append for batch transact

## Anchors system

 - [ ] Chainpoint2.X based
 - [ ] OpenTimestamps

## Backends

 - [ ] HTTP (OpenTimestamp)
 - [ ] Google Drive

## Delivrery system

 - [ ] Mail
 - [ ] Sentry
 - [ ] API (SMS, ...)
