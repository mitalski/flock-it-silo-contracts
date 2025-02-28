// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {Hook} from "silo-core-v2/lib/Hook.sol";
import {FlockItSiloWrapper} from "./FlockItSiloWrapper.sol";
import "forge-std/console.sol";

/**
 * @title FlockItBorrowExecutorHook
 * @notice A hook that executes arbitrary code after a borrow action on a Silo
 * @dev This hook works with FlockItSiloWrapper to execute code after borrowing
 *
 * Flow:
 * 1. User calls borrow() on FlockItSiloWrapper with execution code
 * 2. Wrapper stores code and calls Silo.borrow()
 * 3. Silo calls this hook's afterAction()
 * 4. Hook gets and executes the stored code
 */
contract FlockItBorrowExecutorHook is BaseHookReceiver {
    FlockItSiloWrapper public wrapper;
    address public monitoredSilo;  // The silo this hook is monitoring
    address public owner;          // Owner for potential future upgrades

    error FlockItBorrowExecutorHook_InvalidWrapper();
    error FlockItBorrowExecutorHook_InvalidSilo();
    error FlockItBorrowExecutorHook_ExecutionFailed();
    error FlockItBorrowExecutorHook_AlreadyInitialized();
    error FlockItBorrowExecutorHook_NotOwner();

    event Debug(string message, bytes data);
    event DebugAddress(string message, address addr);

    bool private initialized;  // Prevents wrapper from being changed after initialization

    modifier onlyOwner() {
        if (msg.sender != owner) revert FlockItBorrowExecutorHook_NotOwner();
        _;
    }

    constructor() {
        _disableInitializers();  // Prevents initialization of implementation contract
    }

    /**
     * @notice Sets the wrapper contract that this hook will interact with
     * @dev Can only be called once during initialization
     * @param _wrapper Address of the FlockItSiloWrapper contract
     */
    function setWrapper(address _wrapper) external {
        if (initialized) revert FlockItBorrowExecutorHook_AlreadyInitialized();
        if (_wrapper == address(0)) revert FlockItBorrowExecutorHook_InvalidWrapper();
        wrapper = FlockItSiloWrapper(_wrapper);
        initialized = true;
    }

    /**
     * @notice Initializes the hook with the silo configuration
     * @dev Sets up which silo to monitor and configures it to trigger on borrows
     */
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external initializer override {
        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);
        owner = msg.sender;

        // Get silos from config
        (address silo0, address silo1) = _siloConfig.getSilos();
        if (silo0 == address(0) && silo1 == address(0)) revert FlockItBorrowExecutorHook_InvalidSilo();

        // Use the first non-zero silo address
        monitoredSilo = silo0 != address(0) ? silo0 : silo1;

        // Configure hook to trigger after borrow for the monitored silo
        (uint256 hooksBefore, uint256 hooksAfter) = _hookReceiverConfig(monitoredSilo);
        hooksAfter = Hook.addAction(hooksAfter, Hook.BORROW);
        _setHookConfig(monitoredSilo, hooksBefore, hooksAfter);
    }

    function beforeAction(address, uint256, bytes calldata) external pure override {
        return; // No checks needed before the action
    }

    /**
     * @notice Helper function to make external calls
     * @dev Used by the hook to execute the stored code
     */
    function call(address target, bytes memory data) external returns (bool, bytes memory) {
        return target.call(data);
    }

    /**
     * @notice Called after a Silo action (like borrow)
     * @dev If the action is a borrow on the monitored silo:
     * 1. Gets execution code from wrapper
     * 2. Executes the code
     * 3. Resets the wrapper's execution state
     */
    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput) external override {
        console.log("Hook: afterAction called for silo:", _silo);
        console.log("Hook: action:", _action);
        console.log("Hook: monitored silo:", monitoredSilo);

        if (_silo == monitoredSilo && Hook.matchAction(_action, Hook.BORROW)) {
            emit DebugAddress("Hook called for silo", _silo);
            console.log("Hook: matched silo and action");

            // Get the execution code from the wrapper
            bytes memory executionCode = wrapper.getExecutionCode();
            emit Debug("Execution code retrieved", executionCode);
            console.log("Hook: got execution code, length:", executionCode.length);

            // Execute the code
            (bool success,) = address(this).call(executionCode);
            emit Debug("Execution result", abi.encode(success));
            console.log("Hook: execution result:", success);

            if (!success) revert FlockItBorrowExecutorHook_ExecutionFailed();

            // Reset the wrapper's executing flag
            wrapper.finishExecution();
        }
    }
}
