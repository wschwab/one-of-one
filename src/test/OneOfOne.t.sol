// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../OneOfOne.sol";

interface CheatCodes {
  function prank(address) external;
  function expectRevert(bytes calldata msg) external;
  function expectRevert(bytes4) external;
  function expectEmit(
    bool,
    bool,
    bool,
    bool
  ) external;
}

contract ContractTest is DSTest {
  OneOfOne ooo;
  CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
  address owner = address(0x7BfAf4C59aA4F011672b8e77789e1eb41abd654d);

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  function setUp() public {
    cheats.expectEmit(true, true, true, false);
    emit Transfer(address(0), owner, 0);
    ooo = new OneOfOne(
      address(0x314159265dD8dbb310642f98f50C066173C1259b),
      0xb77f95208cec8af4dec158916be641e4f07614e1fa019686396b7a6da91aa985
    );
  }

  function testExample() public {
    assertTrue(true);
  }

  function testName() public {
    assertEq(ooo.name(), "1-of-1 Soulbound");
  }

  function testSymbol() public {
    assertEq(ooo.symbol(), "1O1S");
  }

  function testOwnerOf() public {
    assertEq(ooo.ownerOf(0), owner);
  }

  function testBalanceOf(address accts) public {
    assertEq(ooo.balanceOf(owner), 1);
    assertEq(ooo.balanceOf(accts), 0);
  }

  function testURI() public {
    assertEq(ooo.tokenURI(0), "ipfs:QmPBAmzESVbx88Vtd94dmg8GCy2q4xLU3zxJfAc3puC4tW");
  }

  function testResolveAddress() public {
    assertEq(ooo.resolveAddress(), owner);
  }

  function testSupportsInterface() public {
    // ERC721
    assertTrue(ooo.supportsInterface(bytes4(0x80ac58cd)));
    // ERC721Metadata
    assertTrue(ooo.supportsInterface(bytes4(0x5b5e139f)));
    // ERC165
    assertTrue(ooo.supportsInterface(bytes4(0x01ffc9a7)));
    // mandated by ERC165 to be false
    assertTrue(!ooo.supportsInterface(bytes4(0xffffffff)));
    // lastly, a random interface to be false
    assertTrue(!ooo.supportsInterface(bytes4(0xabcdef01)));
  }

  function testOwnerOfOnNonexistant() public {
    cheats.expectRevert(OneOfOne.TokenIdDoesNotExist.selector);
    ooo.ownerOf(1);
  }

  function testURIOnNonExistant() public {
    cheats.expectRevert(OneOfOne.TokenIdDoesNotExist.selector);
    ooo.tokenURI(1);
  }

  function testSoulbound(address target, uint256 tokenId) public {
    cheats.expectRevert(
       abi.encodeWithSelector(
        OneOfOne.Soulbound.selector, 
        bytes("SOULBOUND")
      )
    );
    cheats.prank(owner);
    ooo.safeTransferFrom(owner, target, tokenId);

    cheats.expectRevert(
      abi.encodeWithSelector(
        OneOfOne.Soulbound.selector, 
        bytes("SOULBOUND")
      )
    );
    cheats.prank(owner);
    ooo.safeTransferFrom(owner, target, tokenId, bytes("hello, revert"));

    cheats.expectRevert(
      abi.encodeWithSelector(
        OneOfOne.Soulbound.selector, 
        bytes("SOULBOUND")
      )
    );
    cheats.prank(owner);
    ooo.transferFrom(owner, target, tokenId);

    cheats.expectRevert(
      abi.encodeWithSelector(
        OneOfOne.Soulbound.selector, 
        bytes("SOULBOUND")
      )
    );
    cheats.prank(owner);
    ooo.approve(target, tokenId);

    cheats.expectRevert(
      abi.encodeWithSelector(
        OneOfOne.Soulbound.selector, 
        bytes("SOULBOUND")
      )
    );
    cheats.prank(owner);
    ooo.setApprovalForAll(target, true);

    assertTrue(!ooo.isApprovedForAll(owner, target));
  }

  function testSelfDestructByNonOwner() public {
    cheats.expectRevert(OneOfOne.Unauthorized.selector);
    ooo.selfDestruct();
  }
}
