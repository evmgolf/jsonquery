// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {Decimal} from "codec/Decimal.sol";
import {JSONQuery, JSONExecutor} from "../JSONQuery.sol";

contract JSONQueryTest is Test {
  using JSONQuery for bytes;
  using Decimal for uint;
  JSONExecutor json;

  function setUp() public {
    json = new JSONExecutor();
  }

  function testBuildQuery() public {
    bytes("").query("data").queryArray(0).queryLength();
  }

  function testExecute() public {
    bytes memory result = json.execute("data/basic.json", bytes("").query("key"));
    assertEq(result, "value");
  }

  function testReadLength() public {
    uint result = json.readLength("data/array.json", bytes("").query(""));
    assertEq(result, 10);
  }

  function testReadArray() public {
    bytes[] memory results = json.readArray("data/array.json", bytes("").query(""), "");
    assertEq(results.length, 10);
    for (uint i=0;i<results.length;i++) {
      assertEq(results[i], i.decimal());
    }
  }
}
