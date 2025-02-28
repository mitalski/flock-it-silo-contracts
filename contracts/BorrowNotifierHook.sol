// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {Hook} from "silo-core-v2/lib/Hook.sol";
import "./TestDummy.sol";

contract BorrowNotifierHook is BaseHookReceiver {
    TestDummy public testDummy;
    address public monitoredSilo;

    error BorrowNotifierHook_InvalidTestDummy();
    error BorrowNotifierHook_InvalidSilo();

    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external initializer override {
        (/* address owner */, address _testDummy) = abi.decode(_data, (address, address));
        if (_testDummy == address(0)) revert BorrowNotifierHook_InvalidTestDummy();

        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);
        testDummy = TestDummy(_testDummy);

        // Get silos from config
        (address silo0, address silo1) = _siloConfig.getSilos();
        if (silo0 == address(0) && silo1 == address(0)) revert BorrowNotifierHook_InvalidSilo();

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

    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput) external override {
        if (_silo == monitoredSilo && Hook.matchAction(_action, Hook.BORROW)) {
            (uint256 amount,,) = abi.decode(_inputAndOutput, (uint256, address, address));
            testDummy.registerBorrowCall(amount);
        }
    }
}
