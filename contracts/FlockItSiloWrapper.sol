// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import "forge-std/console.sol";

/**
 * @title FlockItSiloWrapper
 * @notice Wraps Silo borrow operations to enable post-borrow code execution
 * @dev Works with FlockItBorrowExecutorHook to execute code after borrowing
 *
 * Flow:
 * 1. User calls borrow() with execution code
 * 2. Wrapper stores code and sets isExecuting flag
 * 3. Wrapper calls Silo.borrow()
 * 4. Silo triggers hook which gets code from wrapper
 * 5. After execution, hook calls finishExecution()
 */
contract FlockItSiloWrapper {
    ISilo public immutable silo;           // The Silo contract to wrap
    bytes private currentExecutionCode;     // Code to execute after borrow
    bool public isExecuting;               // Flag to track execution state

    error FlockItSiloWrapper_NotExecuting();

    event Debug(string message, bytes data);

    /**
     * @notice Wraps a Silo borrow operation with post-borrow execution
     * @param _silo Address of the Silo contract
     */
    constructor(address _silo) {
        silo = ISilo(_silo);
    }

    /**
     * @notice Wraps a Silo borrow operation with post-borrow execution
     * @param amount Amount to borrow
     * @param recipient Recipient of the borrowed amount
     * @param executionCode Code to execute after the borrow
     */
    function borrow(uint256 amount, address recipient, bytes calldata executionCode) external returns (uint256) {
        emit Debug("Storing execution code", executionCode);
        console.log("Wrapper: storing execution code, length:", executionCode.length);

        // Store the execution code for this transaction
        currentExecutionCode = executionCode;
        isExecuting = true;  // Set executing flag

        // Perform the borrow
        uint256 borrowed = silo.borrow(amount, recipient, msg.sender);
        console.log("Wrapper: borrow completed, amount:", borrowed);

        emit Debug("Borrow completed", abi.encode(borrowed));

        // Note: isExecuting is still true here, will be reset by the hook
        return borrowed;
    }

    /**
     * @notice Called by the hook after executing the code
     * @dev Resets the execution state
     */
    function finishExecution() external {
        isExecuting = false;
    }

    /**
     * @notice Gets the stored execution code
     * @dev Only callable during execution (between borrow and finish)
     */
    function getExecutionCode() external view returns (bytes memory) {
        console.log("Wrapper: getExecutionCode called, isExecuting:", isExecuting);
        if (!isExecuting) revert FlockItSiloWrapper_NotExecuting();
        console.log("Wrapper: returning execution code, length:", currentExecutionCode.length);
        return currentExecutionCode;
    }
}
