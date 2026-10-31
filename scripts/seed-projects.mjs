// Run after deployment: set CONTRACT_ADDRESS and use a wallet client as OPERATOR.
export const sampleProjects=['Tamil wallet-document translation','Kannada wallet-document translation','Marathi Solidity video series','Guwahati student Ethereum club','Tier-3 meetup kit','Hindi i18n package','QR-ticketing library','Women builders study group','College node operator guide','Local-language security glossary','Accessibility audit guide','Sepolia faucet handbook'];
console.log(sampleProjects.map((metadata,i)=>`${i}: ${metadata}`).join('\n'));
