// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.13;

import {Decimal} from "codec/Decimal.sol";
import {Quote} from "codec/Quote.sol";
import {Bash} from "bash/Bash.sol";

library JSONQuery {
  using Decimal for uint;

  function query(bytes memory selector, bytes memory name) internal pure returns (bytes memory) {
    return bytes.concat(selector, ".", name);
  }

  function queryArray(bytes memory selector, uint index) internal pure returns (bytes memory) {
    return bytes.concat(selector, "[", index.decimal(), "]");
  }

  function queryLength(bytes memory selector) internal pure returns (bytes memory) {
    return bytes.concat(selector, "|length");
  }
}

contract JSONExecutor {
  using Quote for bytes;
  using JSONQuery for bytes;
  using Decimal for bytes;

  Bash bash;

  constructor() {
    bash = new Bash();
  }

  function execute(bytes memory filename, bytes memory query) public returns (bytes memory) {
    return bash.run(bytes.concat(
      "echo 0x$(jq -j ",
      query.quote("'"),
      " ",
      filename,
      "|xxd -p|tr -d '\n')"
    ));
  }

  function readLength(bytes memory filename, bytes memory selector) public returns (uint) {
    return execute(filename, selector.queryLength()).decodeUint();
  }

  function readArray(bytes memory filename, bytes memory arraySelector, bytes memory itemSelector) public returns (bytes[] memory results) {
    uint length = readLength(filename, arraySelector);
    results = new bytes[](length);
    for (uint i=0; i<length;i++) {
      bytes memory baseSelector = arraySelector.queryArray(i);
      if (itemSelector.length > 0) {
        baseSelector = bytes.concat(baseSelector, itemSelector);
      }
      results[i] = execute(filename, baseSelector);
    }
  }
}
