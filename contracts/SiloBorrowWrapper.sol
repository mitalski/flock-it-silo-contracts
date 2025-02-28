// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";

contract SiloBorrowWrapper {
    ISilo public immutable silo;

    constructor(address _silo) {
        silo = ISilo(_silo);
    }

    function borrow(uint256 amount, address recipient) external returns (uint256) {
        return silo.borrow(amount, recipient, msg.sender);
    }
}
