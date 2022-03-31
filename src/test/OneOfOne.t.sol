// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../OneOfOne.sol";

contract ContractTest is DSTest {
  OneOfOne ooo;

  function setUp() public {
    ooo = new OneOfOne(
      "Test",
      "TEST",
      0x794a812f44e93ff8a7c1ee0fc2809ec57bca87c9162b20c210ea0d1dea978928,
      address(0x314159265dD8dbb310642f98f50C066173C1259b)
    )
  }

  function testExample() public {
    assertTrue(true);
  }

  function testOwnerOf() public {}
  function testBalanceOf() public {}
  function testURI() public {}
  function testFailOwnerOf() public {}
  function testFailBalanceOf() public {}
  function testFailURI() public {}
}
