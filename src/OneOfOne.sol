// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ENS {
  function resolver(bytes32 node) external returns(address);
}

/// @title 1-of-1 optimized Soulbound NFT contract
/// @author wschwab
/// @notice based on idea from Ross: https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c
/// @dev ERC721 template based on Solmate
/// @dev NFT maps to ENS name instead of address
contract OneOfOne {
  /// @dev event will only emit on mint, can hardcode from and tokenId
  event Transfer(address indexed 0, address indexed to, uint256 indexed 0);

  error DoesNotExist();
  error EnsCallFailed();
  error ResolverCallFailed();

  string public immutable name;
  string public immutable symbol;
  string internal immutable URI;
  /// @notice there is only one NFT, so we don't need a mapping
  /// @dev bytes32 is used since we're mapping to an ENS name
  bytes32 internal immutable owner;

  ENS immutable ens;

  constructor(
      string memory _name, 
      string memory _symbol,
      string memory _URI,
      address _ens
  ) {
    ens = ENS(_ens);
    _mint(msg.sender, 0);

    URI = _URI;
  }

  function ownerOf(uint256 tokenId) public view returns(address) {
    //TODO: encode calls
    (bool success, bytes memory returndata) = ens.staticall();
    if(!success) revert EnsCallFailed();
    address resolver = address(returndata);
    (success, returndata) = resolver.staticall();
    return address(returndata);
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    if(tokenId != 0) revert DoesNotExist();
    return URI;
  }

  function _mint(address to, uint256 id) internal {
      balanceOf[to] = 1;

      ownerOf[id] = to;

      emit Transfer(address(0), to, id);
  }
}
