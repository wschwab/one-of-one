// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../OneOfOne.sol";

contract ContractTest is DSTest {
  OneOfOne ooo;

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

  function testName() public {}
  function testSymbol() public {}
  function testOwnerOf() public {}
  function testBalanceOf() public {}
  function testURI() public {}
  function testResolveAddress() public {}
  function testSupportsInterface() public {}
  function testSelfDestruct() public {}
  function testFailOwnerOf() public {}
  function testFailBalanceOf() public {}
  function testFailURI() public {}
  function testSoulbound() public {}
}
