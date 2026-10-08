# RUGAI coin kit

Fixed-supply Solana token for the [RUGAI scanner](https://rugai.grok.me).

This repo does not mint a coin by itself. You run the script from a wallet you control. The script creates the mint, mints the full supply to that wallet, then disables mint authority and freeze authority. After that, supply cannot grow and accounts cannot be frozen by the creator.

This is not a promise of price, liquidity, or utility. The scanner score is a heuristic, not financial advice. This project is not affiliated with, endorsed by, or sponsored by xAI or X.

An unrelated token already uses the name RUG AI on Solana (`9E9qsCpckSZS1snGVgnvuVrrRu1jhZERCNuCaSJgpump`, a pump.fun coin). Do not tell people that address is this project. Publish only the mint this script prints.

## Defaults

| Field | Value |
| --- | --- |
| Name | RUGAI |
| Symbol | RUGAI |
| Decimals | 6 |
| Supply | 1,000,000,000 |
| Network | devnet until you pass `--mainnet` |
| Mint authority | disabled after the initial mint |
| Freeze authority | disabled |

Edit `token.config.json` before you launch if you want a different symbol. `RUGNET` avoids the name collision.

## What you need

- [Solana CLI](https://docs.solana.com/cli/install) with `spl-token`
- A keypair with SOL for fees. Devnet: `solana airdrop 2`. Mainnet: a small amount of SOL, plus more if you later add a liquidity pool yourself.
- Do not commit the keypair. `.gitignore` already excludes `keys/` and `*.keypair.json`.

## Launch

```bash
chmod +x scripts/create-token.sh
./scripts/create-token.sh
./scripts/create-token.sh --mainnet
```

The script writes `mint-address.txt`. Put that address on the site. Anyone can check it on Solscan: mint authority and freeze authority should both be null.

## After the mint

1. Upload `metadata/token.json` and a logo somewhere public. Put the URL in the metadata `image` field.
2. Attach metadata with a Metaplex tool you trust, or leave the mint address as the source of truth until you do.
3. If you add a pool on Raydium or Orca, publish the pool address. A lock claim only counts if the lock is visible on-chain.
4. Keep the scanner free. The tip jar stays at https://paypal.me/mirmobe.

## Site

`site/index.html` is a static landing page in the same terminal style as rugai.grok.me.

WordPress.com at https://mirmobe3.wordpress.com cannot run this script. Use it as the public page: paste the copy from `site/wordpress-paste.txt`, or link the page to this repo and to https://rugai.grok.me. GitHub Pages can host `site/` if you set the Pages source to the `/site` folder.

## Related repos

- Scanner app: https://github.com/Mirmobe/RUGAI_DARK_PORTAL
- Live scanner: https://rugai.grok.me
