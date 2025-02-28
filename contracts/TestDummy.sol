// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract TestDummy {
    bool public wasCalled;
    address public lastCaller;
    uint256 public lastAmount;

    event DummyCalled(address caller, uint256 amount);

    function registerBorrowCall(uint256 amount) external {
        wasCalled = true;
        lastCaller = msg.sender;
        lastAmount = amount;
        emit DummyCalled(msg.sender, amount);
    }

    function reset() external {
        wasCalled = false;
        lastCaller = address(0);
        lastAmount = 0;
    }
}
