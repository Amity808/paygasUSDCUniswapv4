// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CirclePaymaster.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InteractSepolia is Script {
    // Sepolia Testnet Configuration
    address constant SEPOLIA_CIRCLE_PAYMASTER = 0x3BA9A96eE3eFf3A69E2B18886AcF52027EFF8966;
    address constant SEPOLIA_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    
    // Set these to your deployed contract addresses
    address constant CIRCLE_PAYMASTER_INTEGRATION = 0x0000000000000000000000000000000000000000; // TODO: Set your deployed address
    address constant USER = 0x0000000000000000000000000000000000000000; // TODO: Set user address
    address constant RELAYER = 0x0000000000000000000000000000000000000000; // TODO: Set relayer address

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== INTERACTING WITH SEPOLIA TESTNET ===");
        console.log("Deployer:", deployer);
        console.log("Circle Paymaster:", SEPOLIA_CIRCLE_PAYMASTER);
        console.log("USDC:", SEPOLIA_USDC);
        
        if (CIRCLE_PAYMASTER_INTEGRATION == address(0)) {
            console.log("❌ Please set CIRCLE_PAYMASTER_INTEGRATION address in the script");
            return;
        }
        
        vm.startBroadcast(deployerPrivateKey);

        CirclePaymasterIntegration integration = CirclePaymasterIntegration(CIRCLE_PAYMASTER_INTEGRATION);
        IERC20 usdc = IERC20(SEPOLIA_USDC);

        // Example: Query balances
        uint256 deployerUsdc = usdc.balanceOf(deployer);
        uint256 integrationUsdc = usdc.balanceOf(CIRCLE_PAYMASTER_INTEGRATION);
        
        console.log("Deployer USDC:", deployerUsdc);
        console.log("Integration USDC:", integrationUsdc);

        // Example: Get gas estimates
        (uint256 ethCost, uint256 usdcCost) = integration.getGasEstimate(deployer);
        console.log("Estimated ETH cost:", ethCost);
        console.log("Estimated USDC cost:", usdcCost);

        vm.stopBroadcast();
        
        console.log("\n=== INTERACTION SUMMARY ===");
        console.log("Network: Sepolia Testnet");
        console.log("Circle Paymaster Integration:", CIRCLE_PAYMASTER_INTEGRATION);
        console.log("Circle Paymaster Address:", SEPOLIA_CIRCLE_PAYMASTER);
        console.log("USDC Address:", SEPOLIA_USDC);
        console.log("========================\n");
    }
}
