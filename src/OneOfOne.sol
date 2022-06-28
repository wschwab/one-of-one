// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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

  string private constant _URI = "ipfs://QmPBAmzESVbx88Vtd94dmg8GCy2q4xLU3zxJfAc3puC4tW";
  
  /// @notice We assume that `bytes32` is large enough to encode the name and symbol
  bytes32 private immutable _name;
  bytes32 private immutable _symbol;
  /// @notice ENS namehash used to determine NFT owner
  bytes32 private immutable _namehash;
  /// @notice the ENS contract, needed to find the namehash's resolver
  address private immutable _ens;

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
      address ens_,
      bytes32 namehash_,
      bytes32 name_,
      bytes32 symbol_
  ) {
    _ens = ens_;
    _namehash = namehash_;
    _name = name_;
    _symbol = symbol_;

    // NFT is hardcoded in, all we need is the event
    emit Transfer(address(0), resolveAddress(), 0);
  }

  /*///////////////////////////////////////////////////////////////
                          ERC721 VIEW
  //////////////////////////////////////////////////////////////*/

  function balanceOf(address account) public view returns(uint256) {
    return account == resolveAddress() ? 1 : 0;
  }

  function ownerOf(uint256 tokenId) public view returns(address) {
    if(tokenId != 0) revert TokenIdDoesNotExist();
    return resolveAddress();
  }

  function tokenURI(uint256 tokenId) public pure returns (string memory) {
    if(tokenId != 0) revert TokenIdDoesNotExist();
    return _URI;
  }

  function name() public view returns (string memory) {
    return bytes32ToString(_name);
  }

  function symbol() public view returns (string memory) {
    return bytes32ToString(_symbol);
  }

  /*///////////////////////////////////////////////////////////////
                          HELPER FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function resolveAddress() public view returns(address) {
    (bool success, bytes memory returndata) = _ens.staticcall(
      abi.encodeWithSignature(
        "resolver(bytes32)",
        _namehash
      )
    );
    if(!success) revert EnsCallFailed();
    address resolver = abi.decode(returndata, (address));
    (success, returndata) = resolver.staticcall(
      abi.encodeWithSignature(
        "addr(bytes32)",
        _namehash
      )
    );
    if(!success) revert ResolverCallFailed();
    address owner = abi.decode(returndata, (address));
    return owner;
  }

  function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
    return string(abi.encodePacked(_bytes32));
  }

  /*///////////////////////////////////////////////////////////////
                                ERC165
  //////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 iface) public pure returns(bool) {
    return (
      iface == 0x80ac58cd     // ERC721
      || iface == 0x5b5e139f  // ERC721Metadata
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
  ) public pure returns(bool) {
    return false;
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

//         ________                .__                             
// ___  ___\______ \   ____ ______ |  |   ____ ___.__. ___________ 
// \  \/  / |    |  \_/ __ \\____ \|  |  /  _ <   |  |/ __ \_  __ \
//  >    <  |    `   \  ___/|  |_> >  |_(  <_> )___  \  ___/|  | \/
// /__/\_ \/_______  /\___  >   __/|____/\____// ____|\___  >__|   
//       \/        \/     \/|__|               \/         \/       

interface IxDeployer {
  function deploy(uint256 value, bytes32 salt, bytes memory code) external;
  function computeAddress(bytes32 salt, bytes32 codehash) external returns(address);
}

contract DeployToxDeployer {
  address _ens = address(0x314159265dD8dbb310642f98f50C066173C1259b);
  bytes32 _namehash = 0xb77f95208cec8af4dec158916be641e4f07614e1fa019686396b7a6da91aa985;
  bytes32 _name = 0x312d6f662d3120536f756c626f756e6400000000000000000000000000000000; // "1-of-1 Soulbound"
  bytes32 _symbol = 0x314f315300000000000000000000000000000000000000000000000000000000; // "1O1S"
  IxDeployer x = IxDeployer(0x13b0D85CcB8bf860b6b79AF3029fCA081AE9beF2); // Reference: https://github.com/pcaversaccio/xdeployer
  bytes code = abi.encodePacked(type(OneOfOne).creationCode, abi.encode(_ens, _namehash, _name, _symbol));
  bytes32 salt = keccak256(abi.encode("One-of-One Soulbound"));
  constructor() {
    x.deploy(0, salt, code);
    selfdestruct(payable(address(0)));
  }
}
