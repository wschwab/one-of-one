# One-of-One Soulbound

This is a minimalist one-of-one NFT contract with a couple of twists that are perhaps best illustrated with a brief description of what propelled me to write this contract.

I got a profile picture commissioned by [Yamer](https://yamerpro.com), and was interested in turning it into an NFT. [Ross](https://twitter.com/z0r0zzz) had posted an idea for a [one-NFT contract](https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c), but it got me thinking about how it technically still contained a lot of features I didn't need. I also sort of got into a groove where I wanted to see how much of the contract I could set in stone and make completely immutable, for for fun than for any serious reason. I didn't plan on ever selling/transferring the NFT to anyone else, which reminded me of Vitalik's [Soulbound](https://vitalik.eth.limo/general/2022/01/26/soulbound.html) blog post (great read, btw).

Still, what if I wanted to migrate my main account? I'd had an idea for other projects that I realized might be relevant here. I could resolve ownership not based on a specific address, but rather based on an ENS address. I figured that I would always want it at the same address as my ENS, so even if I migrated to a new address, if I migrated my ENS, then the NFT would naturally follow.

With all that in mind, the contract here is designed to only represent one NFT, with the ERC721 metadata (name, symbol, URI) set in the contract code as [constants](https://docs.soliditylang.org/en/v0.8.13/contracts.html#constant-and-immutable-state-variables). ([Immutable](https://docs.soliditylang.org/en/v0.8.13/contracts.html#constant-and-immutable-state-variables) would have been more generalizable, but strings cannot be set to `immutable` as of this writing.) Any ERC721 functions related to transferring are implemented in order to comply with the [ERC721 standard](https://eips.ethereum.org/EIPS/eip-721), but automatically revert. Ownership of the one NFT is determined by determining the address associated with a particular ENS address (namehash), which is set in the constructor.

## How to use this contract for yourself

1. Change the name and symbol to whatever you'd like them to be (otherwise it'll be my pfp)
2. Set the URI to the URI of the JSON metadata for your NFT
3. Deploy (there currently is not a deploy script in this repo) with the arguments of the ENS entry contract (currently `0x314159265dd8dbb310642f98f50c066173c1259b`) and the namehash of the ENS address you're binding the NFT to

(Quick aside: to get the namehash of a particular NFT address, the easiest way is likely cast, a part of [Foundry](https://github.com/gakonst/foundry). If you have Foundry installed, simply run `cast namehash <ENS name>`, eg `cast namehash vitalik.eth`. There is also a `namehash` function in Ethers.js which takes the string of the ENS name as an argument. Afaict there is no function in the ENS contracts for determining the namehash of a particular ENS name.)

This also assumes that you have the metadata somewhere off chain. Maybe building the json in the contract could be a future improvement, though for most images storing the actual image on chain wouldn't be feasible.

## Limitations / Potential Gotchas

Obviously, this contract doesn't work without an ENS address. Further, since it uses the ENS contracts, it can only be deployed on mainnet, at least for now. (ENS has been making strides towards deploying on an L2, and recently got an EIP to Final for a message-bridging structure called [CCIP](https://eips.ethereum.org/EIPS/eip-3668).)

It is impossible to update roughly anything in this contract. The URI cannot be changed, the ENS namehash cannot be changed. Even the ENS contract address can't be changed. (Though you can change resolvers for your ENS name since ENS will be queried to see which resolver to use.)

As a result, a self-destruct function exists. (In fact, it's the only state-changing function on the contract.) The basic idea is that if something serious changes (deciding to let the ENS expire seems like the most plausible option), the contract should simply be destroyed. It can be redeployed with updated information if desired.

This NFT cannot be transferred. You can't even approve someone on this NFT. It is meant to stay bound to one ENS namehash for as long as the contract lives. Really. If you want to transfer it that bad, transfer your ENS to the recipient.

## Additional Ideas / TODO

Using [CREATE3](https://github.com/0xsequence/create3) to make the contract redeployable at the same address if something changes and it needs to redeployed would be a cool addition.

Building the metadata JSON on chain would also be cool, though as mentioned earlier, the image would still likely need to be hosted off chain.

## Additional Details

* This contract was built using Foundry. This makes me look like I know what I'm doing and generally impresses people, which is why I use it.
* There is a test suite which tests every function in the contract other than `selfDestruct`, which I could not figure out a good way to test in Foundry, as I'd want to see the code size go to zero, which is multi-block, and Foundry tests afaik don't have a way to test that. Lmk if I'm wrong about that.
* If you'd like to run the tests, you should do so forking mainnet so the ENS parts work. If you have an API key to a node endpoint (such as Alchemy), then all you need to do is run `forge test --fork-url <URL WITH API KEY HERE>`
* There is a sample metadata JSON in the root of the repo which should be LooksRare/OpenSea compatible, though I have not yet tested that out.
* I'm open to other ideas and suggestions, feel free to open an issue or PR here, or hmu on [Twitter](https://twitter.com/wschwab_)