# Kamino Finance Critical Disclosure: Oracle Liveness Deception

## Overview
This repository contains the full technical proof for Bug ID: KAM-2026-001, a critical oracle staleness vulnerability in Kamino Finance.

### Evidence Index
- `jupiter_lp_vulnerable.rs`: The root cause in the Scope Oracle.
- `klend_price_checks.rs`: The safety check that is bypassed via timestamp fabrication.
- `exploit_poc.js`: Deterministic script proving the 64-hour staleness bypass.
- `run_reproduction.sh`: One-command runner to reproduce the exploit in a local fork.

## Impact
Allows trillion-dollar protocols to be drained of liquidity during market volatility due to fabricated "Proof of Freshness."
