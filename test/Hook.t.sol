// // // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// // import {IHooks} from "v4-core/interfaces/IHooks.sol";
// // import {Test} from "forge-std/Test.sol";
// import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
// // import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
// // import {PoolManager} from "v4-core/PoolManager.sol";
// // import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
// // import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
// // import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
// // import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
// // import {PoolKey} from "v4-core/types/PoolKey.sol";
// // import {Hooks} from "v4-core/libraries/Hooks.sol";
// // import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
// // import {TickMath} from "v4-core/libraries/TickMath.sol";
// // import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
// // import {console} from "forge-std/console.sol";


// // import {CirclePaymasterHook} from "../src/Hook.sol";
// // import {Paymaster} from "../src/Paymaster.sol";

// // // Arbitrum Mainnet: 0x6C973eBe80dCD8660841D4356bf15c32460271C9
// // // Arbitrum Testnet: 0x31BE08D380A21fc740883c0BC434FcFc88740b58
// // // Base Mainnet: 0x6C973eBe80dCD8660841D4356bf15c32460271C9
// // // Base Testnet: 0x31BE08D380A21fc740883c0BC434FcFc88740b58

// // interface ICirclePaymaster {
// //     struct UserOperation {
// //         address sender;
// //         uint256 nonce;
// //         bytes initCode;
// //         bytes callData;
// //         uint256 callGasLimit;
// //         uint256 verificationGasLimit;
// //         uint256 preVerificationGas;
// //         uint256 maxFeePerGas;
// //         uint256 maxPriorityFeePerGas;
// //         bytes paymasterAndData;
// //         bytes signature;
// //     }
    
// //     function validatePaymasterUserOp(
// //         UserOperation calldata userOp,
// //         bytes32 userOpHash,
// //         uint256 maxCost
// //     ) external returns (bytes memory context, uint256 validationData);
    
// //     function postOp(
// //         IPaymaster.PostOpMode mode,
// //         bytes calldata context,
// //         uint256 actualGasCost
// //     ) external;
    
// //     function depositFor(address account) external payable;
// //     function getDeposit(address account) external view returns (uint256);
// // }

// // interface IPaymaster {
// //     enum PostOpMode {
// //         opSucceeded,
// //         opReverted,
// //         postOpReverted
// //     }
// // }


// // contract TestCirclePaymasterHook is Test, Deployers {


// //     using CurrencyLibrary for Currency;
// //     using PoolIdLibrary for PoolKey;

// //     CirclePaymasterHook hook;
// //     MockERC20 usdc;


// //     address user = address(0x123);
// //     address baseTestnetUSDC = 0x31BE08D380A21fc740883c0BC434FcFc88740b58;

// //     function setUp() public {

// //         deployFreshManagerAndRouters();

// //         deployMintAndApprove2Currencies();

// //         usdc = new MockERC20("USDC", "USDC", 6);
// //         usdc.mint(user, 100000e6);
// //          vm.deal(user, 100000e6); 

// //         address hookAddress = address(
// //             uint160(
// //               Hooks.BEFORE_SWAP_FLAG |
// //               Hooks.AFTER_SWAP_FLAG  
// //             )
// //         ); 

// //         vm.txGasPrice(10 gwei);

// //         deployCodeTo(
// //             "CirclePaymasterHook",
// //             abi.encode(manager, ICirclePaymaster(baseTestnetUSDC), address(usdc)), hookAddress
// //         );

// //         hook = CirclePaymasterHook(payable(hookAddress));

// //         (key, ) = initPool(
// //             currency0, currency1,
// //           hook, LPFeeLibrary.DYNAMIC_FEE_FLAG,
// //           SQRT_PRICE_1_1
// //         );

// //         modifyLiquidityRouter.modifyLiquidity(
// //           key, ModifyLiquidityParams({
// //             tickLower: -60,
// //             tickUpper: 60,
// //             liquidityDelta: 100 ether,
// //             salt: bytes32(0)
// //           }),
// //           ZERO_BYTES
// //         );

// //     }

// //     function testDeployment() public {
// //         assertTrue(address(hook) != address(0), "Hook deployment failed");
// //     }

// //     function testUSDCAddress() public {
// //         assertEq(hook.USDC(), address(usdc), "USDC address mismatch");
// //     }

// //     // function testPaymasterAddress() public {
// //     //     assertEq(hook.circlePaymaster(), baseTestnetUSDC, "Paymaster address mismatch");
// //     // }

// //     function testGasEstimate() public {
// //         (uint256 ethCost, uint256 usdcCost) = hook.getGasEstimate(user);
// //         assertTrue(ethCost > 0, "ETH cost should be greater than 0");
// //         assertTrue(usdcCost > 0, "USDC cost should be greater than 0");
// //     }

// // }



// // pragma solidity ^0.8.24;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import {IHooks} from "v4-core/interfaces/IHooks.sol";
// import {Hooks} from "v4-core/libraries/Hooks.sol";
// import {PoolManager} from "v4-core/PoolManager.sol";
// import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
// import {PoolKey} from "v4-core/types/PoolKey.sol";
// import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
// import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
// import {SwapParams} from "v4-core/types/PoolOperation.sol";
// import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
// // import {Deployers} from "v4-core/test/utils/Deployers.sol";
// import {TestERC20} from "v4-core/test/TestERC20.sol";
// import {HookMiner} from "./utils/HookMinner.sol";

// // Import your contracts
// import "../src/Hook.sol";
// import "../src/CirclePaymaster.sol";

// // Mock EntryPoint for testing
// contract MockEntryPoint {
//     mapping(address => uint256) public balanceOf;
    
//     function depositTo(address account) external payable {
//         balanceOf[account] += msg.value;
//     }
    
//     function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external {
//         require(balanceOf[msg.sender] >= withdrawAmount, "Insufficient balance");
//         balanceOf[msg.sender] -= withdrawAmount;
//         (bool success,) = withdrawAddress.call{value: withdrawAmount}("");
//         require(success, "Transfer failed");
//     }
// }

// contract CirclePaymasterHookTest is Test, Deployers {
//     using PoolIdLibrary for PoolKey;
//     using CurrencyLibrary for Currency;
    
//     // Test contracts
//     CirclePaymasterHook hook;
//     TestCirclePaymaster paymaster;
//     MockEntryPoint entryPoint;
//     TestERC20 usdc;
    
//     // Test accounts
//     address alice = makeAddr("alice");
//     address bob = makeAddr("bob");
//     address owner = makeAddr("owner");
    
//     // Pool configuration
//     PoolKey poolKey;
//     PoolId poolId;
    
//     // Test constants
//     uint256 constant INITIAL_USDC_BALANCE = 10000e6; // 10,000 USDC
//     uint256 constant INITIAL_ETH_BALANCE = 100 ether;
//     uint256 constant USDC_TO_ETH_RATE = 3000; // 1 ETH = 3000 USDC
    
//     function setUp() public {
//         // Deploy core contracts
//         deployFreshManagerAndRouters();
        
//         // Deploy mock EntryPoint
//         entryPoint = new MockEntryPoint();
        
//         // Deploy USDC mock token
//         usdc = new TestERC20(2**128);
//         usdc.mint(alice, INITIAL_USDC_BALANCE);
//         usdc.mint(bob, INITIAL_USDC_BALANCE);
        
//         // Deploy TestCirclePaymaster
//         paymaster = new TestCirclePaymaster(IEntryPoint(address(entryPoint)));
        
//         // Fund paymaster with initial ETH
//         vm.deal(address(paymaster), INITIAL_ETH_BALANCE);
//         paymaster.depositFor{value: 10 ether}(address(paymaster));
        
//         // Deploy hook with correct address
//         uint160 flags = uint160(
//             Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG
//         );
        
//         (address hookAddress, bytes32 salt) = HookMiner.find(
//             address(this),
//             flags,
//             type(CirclePaymasterHook).creationCode,
//             abi.encode(address(manager), address(paymaster), address(usdc))
//         );
        
//         hook = new CirclePaymasterHook{salt: salt}(
//             IPoolManager(address(manager)),
//             ICirclePaymaster(address(paymaster)),
//             address(usdc)
//         );
        
//         require(address(hook) == hookAddress, "Hook address mismatch");
        
//         // Authorize the hook in paymaster
//         paymaster.setAuthorizedHook(address(hook), true);
        
//         // Create a test pool
//         poolKey = PoolKey({
//             currency0: Currency.wrap(address(usdc)),
//             currency1: Currency.wrap(address(0)), // ETH
//             fee: 3000,
//             tickSpacing: 60,
//             hooks: IHooks(address(hook))
//         });
        
//         poolId = poolKey.toId();
        
//         // Initialize the pool
//         manager.initialize(poolKey, SQRT_PRICE_1_1, ZERO_BYTES);
        
//         // Setup test accounts
//         vm.deal(alice, INITIAL_ETH_BALANCE);
//         vm.deal(bob, INITIAL_ETH_BALANCE);
        
//         // Fund paymaster deposits for users
//         paymaster.depositFor{value: 1 ether}(alice);
//         paymaster.depositFor{value: 1 ether}(bob);
        
//         // Approve USDC spending
//         vm.prank(alice);
//         usdc.approve(address(hook), type(uint256).max);
        
//         vm.prank(bob);
//         usdc.approve(address(hook), type(uint256).max);
//     }
    
//     function testHookDeployment() public {
//         assertEq(address(hook.circlePaymaster()), address(paymaster));
//         assertEq(hook.USDC(), address(usdc));
//         assertEq(hook.usdcToEthRate(), USDC_TO_ETH_RATE);
//         assertTrue(paymaster.isAuthorizedHook(address(hook)));
//     }
    
//     function testHookPermissions() public {
//         Hooks.Permissions memory permissions = hook.getHookPermissions();
//         assertTrue(permissions.beforeSwap);
//         assertTrue(permissions.afterSwap);
//         assertFalse(permissions.beforeInitialize);
//         assertFalse(permissions.afterInitialize);
//     }
    
//     function testSwapWithoutGaslessMode() public {
//         // Test normal swap without gasless mode
//         SwapParams memory params = SwapParams({
//             zeroForOne: true,
//             amountSpecified: 1000e6, // 1000 USDC
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         uint256 aliceUsdcBefore = usdc.balanceOf(alice);
        
//         vm.prank(alice);
//         manager.swap(poolKey, params, ZERO_BYTES); // Empty hookData = no gasless mode
        
//         // Should work normally without gas payment processing
//         assertTrue(usdc.balanceOf(alice) < aliceUsdcBefore);
//     }
    
//     function testSwapWithGaslessMode() public {
//         uint256 aliceUsdcBefore = usdc.balanceOf(alice);
//         uint256 hookUsdcBefore = usdc.balanceOf(address(hook));
        
//         SwapParams memory params = SwapParams({
//             zeroForOne: true,
//             amountSpecified: 1000e6, // 1000 USDC
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         // Enable gasless mode
//         bytes memory hookData = abi.encode(true);
        
//         vm.prank(alice);
//         manager.swap(poolKey, params, hookData);
        
//         // Check that USDC was deducted for gas payment
//         uint256 aliceUsdcAfter = usdc.balanceOf(alice);
//         uint256 hookUsdcAfter = usdc.balanceOf(address(hook));
        
//         assertTrue(aliceUsdcAfter < aliceUsdcBefore, "Alice USDC should decrease");
//         assertTrue(hookUsdcAfter > hookUsdcBefore, "Hook should receive USDC for gas");
//     }
    
//     function testGasEstimation() public {
//         (uint256 ethCost, uint256 usdcCost) = hook.getGasEstimate(alice);
        
//         assertTrue(ethCost > 0, "ETH cost should be positive");
//         assertTrue(usdcCost > 0, "USDC cost should be positive");
        
//         // Verify conversion rate
//         uint256 expectedUsdcCost = (ethCost * USDC_TO_ETH_RATE) / 1e18;
//         assertEq(usdcCost, expectedUsdcCost, "USDC cost calculation incorrect");
//     }
    
//     function testInsufficientUsdcForGas() public {
//         // Create a user with insufficient USDC
//         address poorUser = makeAddr("poorUser");
//         vm.deal(poorUser, 1 ether);
//         usdc.mint(poorUser, 100e6); // Only 100 USDC
        
//         vm.prank(poorUser);
//         usdc.approve(address(hook), type(uint256).max);
        
//         // Fund paymaster deposit for poor user
//         paymaster.depositFor{value: 0.1 ether}(poorUser);
        
//         SwapParams memory params = SwapParams({
//             zeroForOne: true,
//             amountSpecified: 50e6, // 50 USDC
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         bytes memory hookData = abi.encode(true); // Enable gasless mode
        
//         vm.expectRevert("Insufficient USDC for gas payment");
//         vm.prank(poorUser);
//         manager.swap(poolKey, params, hookData);
//     }
    
//     function testUpdateUsdcToEthRate() public {
//         uint256 newRate = 4000; // 1 ETH = 4000 USDC
        
//         vm.prank(hook.owner());
//         hook.updateUsdcToEthRate(newRate);
        
//         assertEq(hook.usdcToEthRate(), newRate);
        
//         // Test that non-owner cannot update
//         vm.expectRevert();
//         vm.prank(alice);
//         hook.updateUsdcToEthRate(5000);
//     }
    
//     function testPaymasterDeposits() public {
//         uint256 initialDeposit = paymaster.getDeposit(alice);
//         assertTrue(initialDeposit > 0, "Alice should have paymaster deposit");
        
//         uint256 hookDeposit = hook.getUserPaymasterDeposit(alice);
//         assertEq(hookDeposit, initialDeposit, "Hook should return correct deposit");
//     }
    
//     function testEmergencyWithdrawals() public {
//         // Add some USDC to the hook
//         vm.prank(alice);
//         usdc.transfer(address(hook), 1000e6);
        
//         // Add some ETH to the hook
//         vm.deal(address(hook), 1 ether);
        
//         address hookOwner = hook.owner();
//         uint256 ownerUsdcBefore = usdc.balanceOf(hookOwner);
//         uint256 ownerEthBefore = hookOwner.balance;
        
//         // Test USDC withdrawal
//         vm.prank(hookOwner);
//         hook.emergencyWithdrawUsdc(500e6);
        
//         assertEq(
//             usdc.balanceOf(hookOwner),
//             ownerUsdcBefore + 500e6,
//             "Owner should receive USDC"
//         );
        
//         // Test ETH withdrawal
//         vm.prank(hookOwner);
//         hook.emergencyWithdrawEth(0.5 ether);
        
//         assertEq(
//             hookOwner.balance,
//             ownerEthBefore + 0.5 ether,
//             "Owner should receive ETH"
//         );
        
//         // Test that non-owner cannot withdraw
//         vm.expectRevert();
//         vm.prank(alice);
//         hook.emergencyWithdrawUsdc(100e6);
        
//         vm.expectRevert();
//         vm.prank(alice);
//         hook.emergencyWithdrawEth(0.1 ether);
//     }
    
//     function testMultipleSwapsWithGasPayments() public {
//         SwapParams memory params1 = SwapParams({
//             zeroForOne: true,
//             amountSpecified: 500e6,
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         SwapParams memory params2 = SwapParams({
//             zeroForOne: false,
//             amountSpecified: -300e6,
//             sqrtPriceLimitX96: SQRT_PRICE_2_1
//         });
        
//         bytes memory hookData = abi.encode(true);
//         uint256 aliceUsdcInitial = usdc.balanceOf(alice);
        
//         // First swap
//         vm.prank(alice);
//         manager.swap(poolKey, params1, hookData);
        
//         uint256 aliceUsdcAfterFirst = usdc.balanceOf(alice);
//         assertTrue(aliceUsdcAfterFirst < aliceUsdcInitial, "First swap should deduct USDC");
        
//         // Second swap
//         vm.prank(alice);
//         manager.swap(poolKey, params2, hookData);
        
//         uint256 aliceUsdcAfterSecond = usdc.balanceOf(alice);
//         assertTrue(aliceUsdcAfterSecond < aliceUsdcAfterFirst, "Second swap should deduct more USDC");
//     }
    
//     function testGasPaymentEvents() public {
//         SwapParams memory params = SwapParams({
//             zeroForOne: true,
//             amountSpecified: 1000e6,
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         bytes memory hookData = abi.encode(true);
        
//         // Expect events to be emitted
//         vm.expectEmit(true, false, false, true);
//         emit PaymasterDeposit(alice, 0); // Amount will be calculated during test
        
//         vm.expectEmit(true, false, false, false);
//         emit GasPaymentProcessed(alice, 0, 0); // Values will be calculated during test
        
//         vm.prank(alice);
//         manager.swap(poolKey, params, hookData);
//     }
    
//     function testFuzzGasPayments(uint256 swapAmount) public {
//         swapAmount = bound(swapAmount, 100e6, 5000e6); // 100 to 5000 USDC
        
//         SwapParams memory params = SwapParams({
//             zeroForOne: true,
//             amountSpecified: int256(swapAmount),
//             sqrtPriceLimitX96: SQRT_PRICE_1_2
//         });
        
//         bytes memory hookData = abi.encode(true);
//         uint256 aliceUsdcBefore = usdc.balanceOf(alice);
        
//         vm.prank(alice);
//         manager.swap(poolKey, params, hookData);
        
//         uint256 aliceUsdcAfter = usdc.balanceOf(alice);
//         assertTrue(aliceUsdcAfter < aliceUsdcBefore, "USDC should be deducted for gas");
        
//         // Gas cost should be reasonable (less than swap amount)
//         uint256 gasCost = aliceUsdcBefore - aliceUsdcAfter - swapAmount;
//         assertTrue(gasCost < swapAmount / 10, "Gas cost should be reasonable");
//     }
    
//     // Events from the hook contract
//     event GasPaymentProcessed(address indexed user, uint256 usdcAmount, uint256 gasUsed);
//     event PaymasterDeposit(address indexed user, uint256 amount);
// }