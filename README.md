# Quadratic Funding Round

Eligible community members prove membership on-chain. The round applies the square of summed square roots, so a project with many small backers gets more matching support than a whale alone. Contributions, eligibility, the time window, and payouts are all enforced by the contract.

## Deployed Contracts

| Network | Contract | Address |
|---------|----------|---------|
| Sepolia (11155111) | QFRound | `0x255F0ACd12c6540bA79a5D0E7Bf6Cb216320e18c` |

## Setup

```sh
cp .env.example .env
# set operator, dates, root, key and RPC
source .env
```

## Deploy

```sh
forge script script/Deploy.s.sol --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY" --broadcast
```

After deployment, replace `PENDING_DEPLOYMENT` in `deployments/sepolia.json`. Never commit `.env`.

## Phone UI

```sh
cd web && npm install && npm run dev
```

## Eligibility Tree

```sh
npm install && npm run tree
```

## Testing

```sh
forge test
```

## Foundry

https://book.getfoundry.sh/

```sh
$ forge build
$ forge test
$ forge fmt
$ anvil
$ forge --help
$ cast --help
```