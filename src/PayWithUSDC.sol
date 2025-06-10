// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// version
string constant VERSION = "1.0.0";

// imports
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// errors
error PayWithUSDC__InsufficientDeposit();
error PayWithUSDC__InvalidCaller();
error PayWithUSDC__GaslessNotRequested();
error PayWithUSDC__InvalidHookData();

// interfaces, libraries, contracts
interface ICirclePaymaster {
    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }
    
    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 validationData);
    
    function postOp(
        IPaymaster.PostOpMode mode,
        bytes calldata context,
        uint256 actualGasCost
    ) external;
    
    function depositFor(address account) external payable;
    function getDeposit(address account) external view returns (uint256);
}

interface IPaymaster {
    enum PostOpMode {
        opSucceeded,
        opReverted,
        postOpReverted
    }
}

contract PayWithUSDC is BaseHook {
    using LPFeeLibrary for uint24;
    using SafeERC20 for IERC20;

    // Type declarations
    struct GasContext {
        address user;
        uint256 estimatedGasCost;
        uint256 usdcReserved;
        uint256 startGas;
    }

    // State variables
    address public immutable USDC;
    ICirclePaymaster public immutable circlePaymaster;
    uint256 public constant BASE_GAS_COST = 21000;
    uint256 public constant SWAP_GAS_OVERHEAD = 150000;
    mapping(address => uint256) public userGasDeposits;
    mapping(address => bool) public authorizedCallers;
    mapping(bytes32 => GasContext) private gasContexts;

    // Events
    event GasPaymentProcessed(
        address indexed user,
        uint256 usdcAmount,
        uint256 gasUsed,
        bytes32 indexed poolId
    );
    event PaymasterDeposit(address indexed user, uint256 amount);

    // Modifiers
    modifier onlyPoolManager() {
        if (msg.sender != address(poolManager)) revert PayWithUSDC__InvalidCaller();
        _;
    }

    // Functions

    // constructor
    constructor(
        IPoolManager _manager,
        address _usdc,
        ICirclePaymaster _circlePaymaster
    ) BaseHook(_manager) {
        USDC = _usdc;
        circlePaymaster = _circlePaymaster;
        authorizedCallers[address(this)] = true;
    }

    // external
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external override onlyPoolManager returns (bytes4, BeforeSwapDelta, uint24) {
        if (hookData.length == 0) revert PayWithUSDC__InvalidHookData();

        // Decode hookData to check if gasless transaction is requested
        (bool gasless, address user) = abi.decode(hookData, (bool, address));
        if (!gasless) revert PayWithUSDC__GaslessNotRequested();

        // Estimate gas cost
        uint256 estimatedGasCost = BASE_GAS_COST + SWAP_GAS_OVERHEAD;
        uint256 usdcRequired = _estimateUsdcForGas(estimatedGasCost);

        // Check user deposit in paymaster
        uint256 userDeposit = circlePaymaster.getDeposit(user);
        if (userDeposit < usdcRequired) revert PayWithUSDC__InsufficientDeposit();

        // Store gas context
        bytes32 contextKey = keccak256(abi.encode(user, block.timestamp));
        gasContexts[contextKey] = GasContext({
            user: user,
            estimatedGasCost: estimatedGasCost,
            usdcReserved: usdcRequired,
            startGas: gasleft()
        });

        // Reserve USDC (transfer to this contract or paymaster)
        IERC20(USDC).safeTransferFrom(user, address(this), usdcRequired);

        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external override onlyPoolManager returns (bytes4, int128) {
        if (hookData.length == 0) revert PayWithUSDC__InvalidHookData();

        // Decode hookData
        (bool gasless, address user) = abi.decode(hookData, (bool, address));
        if (!gasless) return (this.afterSwap.selector, 0);

        // Retrieve gas context
        bytes32 contextKey = keccak256(abi.encode(user, block.timestamp));
        GasContext memory context = gasContexts[contextKey];
        if (context.user == address(0)) revert PayWithUSDC__InvalidHookData();

        // Calculate actual gas used
        uint256 gasUsed = context.startGas - gasleft();
        uint256 actualUsdcCost = _estimateUsdcForGas(gasUsed);

        // Refund excess USDC or charge additional if needed
        if (actualUsdcCost < context.usdcReserved) {
            uint256 refund = context.usdcReserved - actualUsdcCost;
            IERC20(USDC).safeTransfer(user, refund);
        } else if (actualUsdcCost > context.usdcReserved) {
            uint256 additional = actualUsdcCost - context.usdcReserved;
            IERC20(USDC).safeTransferFrom(user, address(this), additional);
        }

        // Notify paymaster (simplified, actual implementation may vary)
        bytes memory paymasterContext = abi.encode(user, actualUsdcCost);
        // circlePaymaster.postOp(IPaymaster.PostOpMode.opSucceeded, paymasterContext, gasUsed);

        // Emit event
        emit GasPaymentProcessed(user, actualUsdcCost, gasUsed, key.toId());

        // Clean up context
        delete gasContexts[contextKey];

        return (this.afterSwap.selector, 0);
    }

    function depositToPaymaster() external payable {
        circlePaymaster.depositFor{value: msg.value}(msg.sender);
        userGasDeposits[msg.sender] += msg.value;
        emit PaymasterDeposit(msg.sender, msg.value);
    }

    // public
    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // internal
    function _estimateUsdcForGas(uint256 gasAmount) internal pure returns (uint256) {
        // Simplified: Assume 1 gwei gas price and 1 USDC = 1e18 wei for demo
        // In practice, use an oracle for USDC/ETH price
        uint256 gasPrice = 1 gwei; // Example gas price
        uint256 ethCost = gasAmount * gasPrice;
        return ethCost; // Placeholder: Convert ETH to USDC via oracle
    }

    // external & public view & pure functions
    function getUserDeposit(address user) external view returns (uint256) {
        return circlePaymaster.getDeposit(user);
    }

 
}