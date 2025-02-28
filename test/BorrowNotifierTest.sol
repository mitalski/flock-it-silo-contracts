// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/TestDummy.sol";
import "../contracts/BorrowNotifierHook.sol";
import "../contracts/SiloBorrowWrapper.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";
import {DeploySilo} from "./common/DeploySilo.sol";
import {ArbitrumLib} from "./common/ArbitrumLib.sol";
import {Hook} from "silo-core-v2/lib/Hook.sol";

contract BorrowNotifierTest is Test {
    TestDummy public testDummy;
    BorrowNotifierHook public borrowNotifierHook;
    SiloBorrowWrapper public wrapper;
    ISiloConfig public siloConfig;
    address public siloAddress;

    function setUp() public {
        // Fork Arbitrum at a specific block
        vm.createSelectFork(vm.envString("RPC_ARBITRUM"), 302603188);

        // Deploy contracts
        testDummy = new TestDummy();
        BorrowNotifierHook hookImplementation = new BorrowNotifierHook();

        // Deploy silo with hook
        DeploySilo deployer = new DeploySilo();
        bytes memory initData = abi.encode(address(this), address(testDummy));
        siloConfig = deployer.deploySilo(
            ArbitrumLib.SILO_DEPLOYER,
            address(hookImplementation),
            initData
        );

        // Get deployed contract addresses
        borrowNotifierHook = BorrowNotifierHook(_getHookAddress(siloConfig));
        (siloAddress,) = siloConfig.getSilos();
        wrapper = new SiloBorrowWrapper(siloAddress);
    }

    function testBorrowNotification() public {
        uint256 borrowAmount = 1000;

        // Ensure dummy starts clean
        testDummy.reset();
        assertFalse(testDummy.wasCalled());

        // Simulate the hook being called after a borrow
        bytes memory inputData = abi.encode(borrowAmount, address(this), address(this));
        borrowNotifierHook.afterAction(siloAddress, Hook.BORROW, inputData);

        // Verify the notification was received
        assertTrue(testDummy.wasCalled());
        assertEq(testDummy.lastAmount(), borrowAmount);
        assertEq(testDummy.lastCaller(), address(borrowNotifierHook));
    }

    function _getHookAddress(ISiloConfig _siloConfig) internal view returns (address hookAddress) {
        (address siloAddr,) = _siloConfig.getSilos();
        hookAddress = _siloConfig.getConfig(siloAddr).hookReceiver;
    }
}
