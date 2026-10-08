#!/usr/bin/env bash
# Create a fixed-supply SPL token and revoke mint + freeze authority.
# Defaults to devnet and expects the dev wallet. Pass --mainnet only when you mean it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/token.config.json"
NETWORK="devnet"

if [[ "${1:-}" == "--mainnet" ]]; then
  NETWORK="mainnet-beta"
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--mainnet]" >&2
  exit 1
fi

if ! command -v solana >/dev/null || ! command -v spl-token >/dev/null; then
  echo "Install solana and spl-token first." >&2
  exit 1
fi
if ! command -v python3 >/dev/null; then
  echo "python3 is required to read token.config.json" >&2
  exit 1
fi

read_cfg() {
  python3 - "$CONFIG" "$1" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(data[sys.argv[2]])
PY
}

DECIMALS="$(read_cfg decimals)"
SUPPLY="$(read_cfg supply)"
SYMBOL="$(read_cfg symbol)"
LAUNCH="$(python3 - "$CONFIG" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))["wallets"]["launch"])
PY
)"
DEV="$(python3 - "$CONFIG" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))["wallets"]["dev"])
PY
)"

if [[ "$NETWORK" == "mainnet-beta" ]]; then
  EXPECTED="$LAUNCH"
else
  EXPECTED="$DEV"
fi

if [[ "$NETWORK" == "mainnet-beta" ]]; then
  echo "About to mint ${SUPPLY} ${SYMBOL} on MAINNET from ${EXPECTED} and then revoke authorities."
  echo "Type MAINNET to continue:"
  read -r confirm
  [[ "$confirm" == "MAINNET" ]] || { echo "Aborted."; exit 1; }
fi

solana config set --url "$NETWORK" >/dev/null
ACTIVE="$(solana address)"
echo "RPC: $(solana config get | awk '/RPC URL/{print $3}')"
echo "Wallet: $ACTIVE"
echo "Expected signer: $EXPECTED"

if [[ "$ACTIVE" != "$EXPECTED" ]]; then
  echo "Active keypair does not match the expected wallet." >&2
  echo "Devnet expects the dev wallet. Mainnet expects the launch wallet." >&2
  echo "Switch with: solana config set --keypair /path/to/that-wallet.json" >&2
  exit 1
fi

MINT="$(spl-token create-token --decimals "$DECIMALS" | awk '/Address:/{print $2}')"
echo "Mint: $MINT"

ACCOUNT="$(spl-token create-account "$MINT" | awk '/Creating account/{print $3}')"
echo "Token account: $ACCOUNT"

spl-token mint "$MINT" "$SUPPLY" "$ACCOUNT" >/dev/null
echo "Minted ${SUPPLY} ${SYMBOL}"

# Disable both authorities. Supply is now fixed. Accounts cannot be frozen.
spl-token authorize "$MINT" mint --disable >/dev/null
spl-token authorize "$MINT" freeze --disable >/dev/null

printf '%s\n' "$MINT" > "$ROOT/mint-address.txt"
{
  echo "network=$NETWORK"
  echo "signer=$ACTIVE"
  echo "mint=$MINT"
  echo "token_account=$ACCOUNT"
  echo "supply=$SUPPLY"
  echo "decimals=$DECIMALS"
  echo "symbol=$SYMBOL"
  echo "mint_authority=disabled"
  echo "freeze_authority=disabled"
  echo "created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$ROOT/launch-receipt.txt"

echo
echo "Done. Mint written to mint-address.txt"
echo "Verify on https://solscan.io/token/${MINT} that mint and freeze authority are null."
