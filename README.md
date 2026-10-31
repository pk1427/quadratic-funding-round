# Quadratic Funding Round

Eligible community members prove membership on-chain. The round applies the square of summed square roots, so a project with many small backers gets more matching support than a whale alone. Contributions, eligibility, the time window, and payouts are all enforced by the contract.

```sh
forge test
npm install && npm run tree # writes eligibility root and proofs
cp .env.example .env # set operator, dates, root, key and RPC
source .env && forge script script/Deploy.s.sol:Deploy --rpc-url "$SEPOLIA_RPC_URL" --broadcast
cd web && npm install && npm run dev
```

After deployment, replace `PENDING_DEPLOYMENT` in `deployments/sepolia.json`. Never commit `.env`.
