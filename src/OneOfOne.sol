// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/// @title 1-of-1 optimized Soulbound NFT contract
/// @author wschwab
/// @notice based on idea from Ross: https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c
/// @dev ERC721 template based on Solmate
/// @dev NFT maps to ENS name instead of address
contract OneOfOne {
  /*///////////////////////////////////////////////////////////////
                            ERRORS
  //////////////////////////////////////////////////////////////*/

  error TokenIdDoesNotExist();
  error EnsCallFailed();
  error ResolverCallFailed();
  error Soulbound(string message);
  error Unauthorized();

  /*///////////////////////////////////////////////////////////////
                        GLOBAL VARIABLES
  //////////////////////////////////////////////////////////////*/

  string public constant name = "1-of-1 Soulbound";
  string public constant symbol = "1O1S";
  string constant URI = "ipfs:QmPBAmzESVbx88Vtd94dmg8GCy2q4xLU3zxJfAc3puC4tW";
  /// @notice there is only one NFT, so we don't need a mapping
  /// @dev bytes32 is used since we're mapping to an ENS name
  bytes32 internal immutable namehash;
  /// @notice the ENS contract, needed to find the namehash's resolver
  address internal immutable ens;


  /*///////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/

  /// @dev event will only emit on mint, can hardcode from and tokenId
  /// @dev since there are no transfers, we don't need the other 721 events
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
  //////////////////////////////////////////////////////////////*/

  constructor(
      address _ens,
      bytes32 _namehash
  ) {
    ens = _ens;
    namehash = _namehash;

    // NFT is hardcoded in, all we need is the event
    emit Transfer(address(0), msg.sender, 0);
  }

  /*///////////////////////////////////////////////////////////////
                          ERC721 VIEW
  //////////////////////////////////////////////////////////////*/

  function balanceOf(address account) public view returns(uint256) {
    account == resolveAddress() ? 1 : 0;
  }

  function ownerOf(uint256 tokenId) public view returns(address) {
    if(tokenId != 0) revert TokenIdDoesNotExist();
    return resolveAddress();
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    if(tokenId != 0) revert TokenIdDoesNotExist();
    return URI;
  }

  /*///////////////////////////////////////////////////////////////
                          HELPER FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function resolveAddress() public view returns(address) {
    (bool success, bytes memory returndata) = ens.staticcall(
      abi.encodeWithSignature(
        "resolver(bytes32)",
        namehash
      )
    );
    if(!success) revert EnsCallFailed();
    address resolver = abi.decode(returndata, (address));
    (success, returndata) = resolver.staticcall(
      abi.encodeWithSignature(
        "addr(bytes32)",
        namehash
      )
    );
    if(!success) revert ResolverCallFailed();
    address owner = abi.decode(returndata, (address));
    return owner;
  }

  /*///////////////////////////////////////////////////////////////
                                ERC165
  //////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 iface) public pure returns(bool) {
    return (
      iface == 0x80ac58cd     // ERC721
      || iface == 0x150b7a02  // ERC721Metadata
      || iface == 0x01ffc9a7  // ERC165
    );
  }

  /*///////////////////////////////////////////////////////////////
                            SOULBOUND
  //////////////////////////////////////////////////////////////*/

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function approve(
    address approved,
    uint256 _tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function setApprovalForAll(
    address operator,
    bool allowed
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function getApproved(
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function isApprovedForAll(
    address owner,
    address operator
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  /*///////////////////////////////////////////////////////////////
                            SELF-DESTRUCT
  //////////////////////////////////////////////////////////////*/

  /// @notice allows destruction of contract
  /// @dev intended if ENS domain will expire, ENS migrates, or otherwise
  /// @dev can only be called by namehash set in constructor
  function selfDestruct() public {
    address owner = resolveAddress();
    if(msg.sender != owner) revert Unauthorized();
    selfdestruct(payable(owner));
  }
}