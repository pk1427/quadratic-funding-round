import {readFileSync,writeFileSync,mkdirSync}from'node:fs';
import {StandardMerkleTree}from'@openzeppelin/merkle-tree';
const rows=readFileSync('scripts/eligible.csv','utf8').trim().split(/\r?\n/).slice(1).filter(Boolean).map(address=>[address.trim()]);
const tree=StandardMerkleTree.of(rows,['address']);mkdirSync('out',{recursive:true});
const proofs={};for(const [i,v] of tree.entries())proofs[v[0].toLowerCase()]=tree.getProof(i);
writeFileSync('out/eligibility.json',JSON.stringify({root:tree.root,proofs},null,2));console.log(tree.root);
