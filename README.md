# Quadratic Funding Round

Eligible community members contribute with an on-chain Merkle proof. Matching uses the square of summed **per-contributor** square roots, so many small backers have more matching influence than one whale.

## Verified Sepolia deployment

| Item | Value |
| --- | --- |
| Contract | `QFRound` |
| Address | [`0x98e0E8f04ACfA5B4CaBB3B7B5362e63b8529331e`](https://sepolia.etherscan.io/address/0x98e0E8f04ACfA5B4CaBB3B7B5362e63b8529331e) |
| Deployment | [`0x9dd04b60df1e72e2f036460bbc1548580ddbd36b82e1904bddec738dc8f772d0`](https://sepolia.etherscan.io/tx/0x9dd04b60df1e72e2f036460bbc1548580ddbd36b82e1904bddec738dc8f772d0) |
| Network | Sepolia (`11155111`), confirmed `status: 1` |
| Live projects | 12 seeded community projects |

The live round includes Tamil/Kannada wallet docs, Marathi Solidity videos, Guwahati Ethereum club, a Tier-3 meetup kit, Hindi i18n, QR ticketing, and more. The live `0.001 ETH` contribution path has been verified.

## How it works

- `contribute(projectId, proof)` validates eligibility on-chain.
- Amounts come from `msg.value`.
- Repeated contributions use the square-root delta for each contributor.
- After round end, `finalizeMatches()` stores literal `(Σ√c)²` scores and pool shares.
- Project recipients withdraw once; state is written before ETH transfer.
- Matching-pool dust can be reclaimed only after all projects withdraw.

## Test and eligibility tree

```sh
forge test
npm install
npm run tree
```

The Foundry suite covers eligibility, late contributions, square-root delta accounting, early finalization, and double withdrawal. The tree command writes deterministic proofs to `out/eligibility.json`.

## Mobile frontend

```sh
cd web
npm install
npm run dev -- --host 127.0.0.1
```

The frontend reads the live 12-project round, selects a project, obtains the connected wallet’s proof, submits `contribute`, and retains newly submitted transaction links in browser-local activity.

## Re-deploy and seed

```sh
cp .env.example .env
# set PRIVATE_KEY, SEPOLIA_RPC_URL, OPERATOR, ROUND_START, ROUND_END, ELIGIBILITY_ROOT
forge create src/QFRound.sol:QFRound \
  --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY" --broadcast \
  --gas-limit 15000000 \
  --constructor-args "$OPERATOR" "$ROUND_START" "$ROUND_END" "$ELIGIBILITY_ROOT"
```

Then set `QF_ROUND_ADDRESS` locally and run `forge script script/Seed.s.sol:Seed --rpc-url "$SEPOLIA_RPC_URL" --broadcast --gas-estimate-multiplier 1000`. Never commit `.env` or `web/.env`.
