// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../OneOfOne.sol";

interface CheatCodes {
  function prank(address) external;
  function expectRevert(bytes calldata) external;
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
  address wschwab = address(0x7BfAf4C59aA4F011672b8e77789e1eb41abd654d);

  function setUp() public {
    // test event emission, if possible
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
    assertEq(ooo.ownerOf(0), wschwab);
  }

  function testBalanceOf() public {
    assertEq(ooo.balanceOf(wschwab), 1);
  }

  function testURI() public {
    assertEq(ooo.tokenURI(0), "ipfs:QmPBAmzESVbx88Vtd94dmg8GCy2q4xLU3zxJfAc3puC4tW");
  }

  function testResolveAddress() public {
    assertEq(ooo.resolveAddress(), wschwab);
  }

  function testSupportsInterface() public {
    // ERC721
    assertTrue(ooo.supportsInterface(bytes4(0x80ac58cd)));
    // ERC721Metadata
    assertTrue(ooo.supportsInterface(bytes4(0x150b7a02)));
    // ERC165
    assertTrue(ooo.supportsInterface(bytes4(0x01ffc9a7)));
    // TODO: Not working since assertEq doesn't have a bytes4 version
    // // mandated by ERC165
    // assertEq(ooo.supportsInterface(bytes4(0xffffffff)), false);
    // // lastly, a random interface
    // assertEq(ooo.supportsInterface(bytes4(0xabcdef01)), false);
  }

  function testSelfDestruct() public {
    address oooAddress = address(ooo);
    cheats.prank(ooo.resolveAddress());
    ooo.selfDestruct();
    // mine block to trigger destruct
    // expect bytecode size to be 0
  }

  function testOwnerOfOnNonexistant() public {}
  function testBalanceOfOnNonOwner() public {}
  function testURIOnNonExistant() public {}
  function testSoulbound() public {}
  function testSelfDestructByNonOwner() public {}
}
