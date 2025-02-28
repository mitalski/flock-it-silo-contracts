// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/TestDummy.sol";
import "../contracts/FlockItBorrowExecutorHook.sol";
import "../contracts/FlockItSiloWrapper.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";
import {DeploySilo} from "./common/DeploySilo.sol";
import {ArbitrumLib} from "./common/ArbitrumLib.sol";
import {Hook} from "silo-core-v2/lib/Hook.sol";

/**
 * @title FlockItBorrowExecutorTest
 * @notice Tests the interaction between FlockItSiloWrapper and FlockItBorrowExecutorHook
 *
 * Test Flow:
 * 1. Deploy TestDummy contract to verify execution
 * 2. Deploy wrapper with temporary silo address
 * 3. Deploy hook implementation
 * 4. Deploy silo with hook
 * 5. Update wrapper with real silo address
 * 6. Configure hook with wrapper
 * 7. Test borrow with execution:
 *    - Create execution code to call TestDummy
 *    - Call wrapper.borrow()
 *    - Verify TestDummy was called correctly
 */
contract FlockItBorrowExecutorTest is Test {
    TestDummy public testDummy;
    FlockItBorrowExecutorHook public borrowExecutorHook;
    FlockItSiloWrapper public wrapper;
    ISiloConfig public siloConfig;
    address public siloAddress;

    /**
     * @notice Sets up the test environment
     * @dev Deploys and configures all necessary contracts
     */
    function setUp() public {
        // Fork Arbitrum at a specific block
        vm.createSelectFork(vm.envString("RPC_ARBITRUM"), 302603188);

        // Deploy test dummy
        testDummy = new TestDummy();

        // Deploy wrapper first
        wrapper = new FlockItSiloWrapper(address(0)); // Temporary address
        vm.label(address(wrapper), "Wrapper");

        // Deploy hook implementation
        FlockItBorrowExecutorHook hookImplementation = new FlockItBorrowExecutorHook();
        vm.label(address(hookImplementation), "Hook Implementation");

        // Deploy silo with hook implementation
        DeploySilo deployer = new DeploySilo();
        bytes memory initData = abi.encode(address(this));
        siloConfig = deployer.deploySilo(
            ArbitrumLib.SILO_DEPLOYER,
            address(hookImplementation),
            initData
        );

        // Get silo address and update wrapper
        (siloAddress,) = siloConfig.getSilos();
        vm.label(siloAddress, "Silo");
        wrapper = new FlockItSiloWrapper(siloAddress);

        // Get hook instance
        borrowExecutorHook = FlockItBorrowExecutorHook(_getHookAddress(siloConfig));
        vm.label(address(borrowExecutorHook), "Hook");

        // Set wrapper on the hook
        vm.prank(address(this));
        borrowExecutorHook.setWrapper(address(wrapper));

        // Verify addresses match
        (address currentSilo,) = siloConfig.getSilos();
        require(currentSilo == siloAddress, "Silo address mismatch");
        require(borrowExecutorHook.monitoredSilo() == currentSilo, "Monitored silo mismatch");

        console.log("Setup complete:");
        console.log("- Silo:", siloAddress);
        console.log("- Hook:", address(borrowExecutorHook));
        console.log("- Wrapper:", address(wrapper));
        console.log("- TestDummy:", address(testDummy));
    }

    /**
     * @notice Tests the full borrow and execute flow
     * @dev Verifies that:
     * 1. Execution code is stored correctly
     * 2. Hook is triggered by borrow
     * 3. Execution code is retrieved and executed
     * 4. TestDummy receives the correct call
     */
    function testBorrowExecution() public {
        uint256 borrowAmount = 1000;

        console.log("Test started with borrowAmount:", borrowAmount);
        console.log("TestDummy address:", address(testDummy));
        console.log("Hook address:", address(borrowExecutorHook));
        console.log("Wrapper address:", address(wrapper));
        console.log("Silo address:", siloAddress);

        // Ensure dummy starts clean
        testDummy.reset();
        assertFalse(testDummy.wasCalled());

        // Create execution code that will call the dummy contract
        bytes memory executionCode = abi.encodeWithSignature(
            "call(address,bytes)",
            address(testDummy),
            abi.encodeWithSignature("registerBorrowCall(uint256)", borrowAmount)
        );

        emit log_named_bytes("Execution Code", executionCode);
        emit log_named_address("TestDummy Address", address(testDummy));
        emit log_named_address("Hook Address", address(borrowExecutorHook));

        console.logBytes(executionCode);

        // Mock necessary calls for the borrow
        vm.mockCall(
            siloAddress,
            abi.encodeWithSignature("borrow(uint256,address,address)"),
            abi.encode(borrowAmount)
        );

        console.log("Starting borrow simulation...");

        // Simulate the borrow with execution code
        vm.startPrank(address(this));

        // First store the execution code
        wrapper.borrow(borrowAmount, address(this), executionCode);

        console.log("Borrow called, now triggering hook...");

        // Then simulate the hook being called after borrow
        bytes memory inputData = abi.encode(borrowAmount, address(this), address(this));
        borrowExecutorHook.afterAction(siloAddress, Hook.BORROW, inputData);

        console.log("Hook triggered");

        vm.stopPrank();

        // Verify the execution was received
        assertTrue(testDummy.wasCalled(), "TestDummy was not called");
        assertEq(testDummy.lastAmount(), borrowAmount, "Wrong amount recorded");
        assertEq(testDummy.lastCaller(), address(borrowExecutorHook), "Wrong caller recorded");
    }

    function _getHookAddress(ISiloConfig _siloConfig) internal view returns (address hookAddress) {
        (address siloAddr,) = _siloConfig.getSilos();
        hookAddress = _siloConfig.getConfig(siloAddr).hookReceiver;
    }
}
