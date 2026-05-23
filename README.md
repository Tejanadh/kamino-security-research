# Kamino Finance Critical Disclosure: Oracle Liveness Deception (KAM-2026-001)

**Severity:** Critical  
**Status:** Live on Mainnet  
**Program ID:** `HFn8GnPADiny6XqUoWE8uRPPxb29ikn4yTuPa9MF2fWJ` (release/v0.35.0)  
**Affected Oracles:** Jupiter LP (JupiterLpFetch), Jito Restaking (VRT), Adrena LP

---

## Overview

This repository contains the full technical proof for **KAM-2026-001**, a critical oracle staleness vulnerability in Kamino Finance's Scope oracle aggregator.

### Root Cause
The `get_price_no_recompute` function in derived-asset oracles (Jupiter LP, Jito Restaking, Adrena LP) uses `clock.unix_timestamp` instead of the actual observation timestamp from the source protocol. This completely bypasses KLend's `max_age_price_seconds` protection (300s), allowing stale prices to be accepted as fresh.

---

## Disclosure Note

Responsible disclosure was attempted via direct email on **May 8, 2026**. No response was received after 14 days. This full technical report + deterministic PoC is published for transparency and to encourage a responsible fix.

---

## Evidence

| File                        | Description                                      |
|----------------------------|--------------------------------------------------|
| `jupiter_lp_vulnerable.rs` | Root cause in Scope Oracle (JupiterLpFetch Index 124) |
| `klend_price_checks.rs`    | The safety check bypassed via timestamp fabrication |
| `exploit_poc.js`           | Deterministic PoC proving 64-hour staleness bypass (verified on local fork + live program ID) |
| `run_reproduction.sh`      | One-command script to reproduce the exploit in a local fork |

---

## Impact

This vulnerability allows an attacker to force Scope to sign off on stale high prices during market crashes.

- **JLP Market TVL:** ~$1.05B (with ~$700M debt secured by JLP)
- **Attack Scenario:** A 16-20% price drop during the staleness window pushes positions into liquidation, creating systemic bad debt.
- **Estimated Funds at Risk:** $100M+ (conservative) to $500M+ in a major volatility event.

---

## Systemic Finding

This is **not** an isolated JLP bug. The same `clock.unix_timestamp` fabrication pattern exists across multiple derived-asset oracles in Scope:

| Oracle Type       | Timestamp Source          | Status      | Risk Level |
|-------------------|---------------------------|-------------|------------|
| Pyth / Lazer      | Source Account            | **Secure**  | Low        |
| Switchboard       | Source Account            | **Secure**  | Low        |
| **Jupiter LP**    | `clock.unix_timestamp`    | **Vulnerable** | **Critical** |
| **Jito Restaking (VRT)** | `clock.unix_timestamp` | **Vulnerable** | **Critical** |
| **Adrena LP**     | `clock.unix_timestamp`    | **Vulnerable** | **Critical** |
| Meteora / Orca    | `clock.unix_timestamp`    | By-Design   | Medium     |

**Conclusion:** Scope has a systemic architectural flaw in its derived-asset oracle logic. The developers defaulted to `clock.unix_timestamp` for any asset that wasn't a standard Pyth/Switchboard feed, accidentally disabling the most important safety feature in a lending protocol: the staleness kill-switch.

---

## Recommended Fix

Scope should use the **actual observation timestamp** from the source protocol (e.g. `aum_usd_updated_at` from Jupiter Pool state) instead of `clock.unix_timestamp` for all derived-asset oracles.

---

**Researcher:** Tejanadh  
**Date:** May 22, 2026  
**PoC Verified On:** Local fork + Live Mainnet program ID
