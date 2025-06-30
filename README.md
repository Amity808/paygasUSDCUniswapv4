# CirclePaymasterHook - Uniswap V4 Hookathon Project

## Overview

CirclePaymasterHook is a Uniswap V4 hook that integrates with Circle's ERC-4337 Paymaster service, enabling users to pay gas fees in USDC instead of native ETH for swap operations. This innovative solution enhances user experience by offering gasless transactions, making DeFi more accessible and cost-efficient. The project leverages Uniswap V4's hook architecture and Circle's paymaster infrastructure to provide seamless gas fee payments in stablecoins.

## Features

- **Gasless Swaps with USDC**: Users can pay gas fees in USDC, eliminating the need for native ETH.
- **Circle Paymaster Integration**: Seamlessly connects with Circle’s ERC-4337 Paymaster for secure and efficient gas payment processing.
- **Dynamic Gas Estimation**: Accurately estimates gas costs for swaps and converts them to USDC using a simplified price oracle (Chainlink-compatible in production).
- **Refund Mechanism**: Refunds excess USDC reserved for gas if actual usage is lower than estimated.
- **Secure and Auditable**: Built with OpenZeppelin's `Ownable` and `ReentrancyGuard` for robust security and access control.
- **Admin Controls**: Allows authorized updates to USDC-to-ETH rates and emergency withdrawal functions for safety.

## Contracts

The project consists of three main contracts:

1. **CirclePaymasterHook** (`Hook.sol`)
   - A Uniswap V4 hook that intercepts `beforeSwap` and `afterSwap` to manage gas payments in USDC.
   - Interacts with the Circle Paymaster Integration contract to process and finalize gas payments.
   - Tracks gas context per swap to ensure accurate accounting and refunds.

2. **CirclePaymasterIntegration** (`CirclePaymasterIntegration.sol`)
   - Handles USDC gas payments and interacts with Circle’s Paymaster contract.
   - Manages user deposits, reimbursements to relayers, and Circle Paymaster deposits.
   - Includes admin functions for updating price rates and authorizing callers.

3. **Paymaster** (`Paymaster.sol`)
   - An ERC-4337 Paymaster implementation that supports gas payment validation and post-operation handling.
   - Manages ETH deposits, withdrawals, and reimbursements in USDC for relayers.
   - Ensures only authorized hooks or owners can perform sensitive operations.

## How It Works

1. **Swap Initiation**:
   - Users initiate a swap on a Uniswap V4 pool with the `CirclePaymasterHook` enabled.
   - Hook data specifies whether to use gasless mode (`useGaslessMode`) and the actual user address (for relayer scenarios).

2. **Before Swap** (`_beforeSwap`):
   - If gasless mode is enabled, the hook estimates gas costs using predefined constants (`BASE_GAS_COST` + `SWAP_GAS_OVERHEAD`).
   - Converts estimated ETH cost to USDC using the `usdcToEthRate`.
   - Verifies user’s USDC balance and allowance, then transfers USDC to the `CirclePaymasterIntegration` contract.
   - Stores gas context (user, estimated cost, USDC reserved, start gas) for the swap.

3. **After Swap** (`_afterSwap`):
   - Retrieves gas context and calculates actual gas used.
   - Converts actual gas cost to USDC and refunds any excess USDC to the user via the `CirclePaymasterIntegration` contract.
   - Emits `GasPaymentProcessed` event with details of the transaction.

4. **Circle Paymaster Integration**:
   - Processes USDC payments and deposits ETH to Circle’s Paymaster for gas accounting.
   - Reimburses relayers in USDC for paying ETH gas on behalf of users.
   - Provides view functions for checking user deposits and Circle Paymaster balances.

5. **Paymaster**:
   - Validates user operations per ERC-4337 standards, ensuring sufficient deposits and valid senders.
   - Handles post-operation logic, refunding unused gas or charging actual costs.
   - Supports batch deposits and hook authorization for integration with Uniswap V4.

## Key Innovations

- **User-Centric Design**: Simplifies DeFi interactions by allowing stablecoin gas payments, reducing exposure to ETH price volatility.
- **Scalable Architecture**: Modular design with separate hook and paymaster contracts for easy integration and upgrades.
- **Gas Efficiency**: Optimized gas estimation and refund mechanisms to minimize user costs.
- **Compatibility**: Built for Uniswap V4 and Circle’s Paymaster, with potential for broader ERC-4337 ecosystem adoption.

## Installation and Setup

### Prerequisites
- Solidity ^0.8.24
- Foundry for testing and deployment
- OpenZeppelin Contracts v5.x
- Uniswap V4 Core and Periphery libraries
- Access to Circle’s Paymaster contract (mainnet/testnet addresses provided in `CirclePaymasterIntegration.sol`)

### Deployment
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Amity808/paygasUSDCUniswapv4
   cd paygasUSDCUniswapv4
   ```

# Contract Deployment and Management Guide

## Install Dependencies
```bash  
forge install  
```

## Compile Contracts
```bash  
forge build  
```

## Deploy Contracts
- Deploy Paymaster with the EntryPoint address.
- Deploy CirclePaymasterIntegration with Circle Paymaster and USDC token addresses.
- Deploy CirclePaymasterHook with the Uniswap V4 PoolManager, CirclePaymasterIntegration, and USDC addresses.
- Authorize the hook in the Paymaster contract using `setAuthorizedHook`.


# Usage

## Initiate a Swap
- Call the Uniswap V4 pool with CirclePaymasterHook enabled.
- Include hook data:
  - `abi.encode(true, userAddress)` for gasless mode.
  - `abi.encode(false)` for standard mode.

## Monitor Events
- **GasPaymentProcessed**: Tracks USDC paid and gas used.
- **PaymasterDeposit**: Records ETH deposits to CirclePaymaster.
- **RelayerReimbursed**: Logs USDC reimbursements to relayers.

## Admin Management
- Use `setAuthorizedCaller` to manage authorized hook contracts.
- Monitor deposits with `getUserGasDeposit` and `getCirclePaymasterDeposit`.
- Execute emergency withdrawals if needed (owner only).

## Testing
## Run Tests Using Foundry
```bash  
forge test  
```

# Test Suites Coverage
- Gas payment processing and refunds
- USDC transfers and allowances
- Paymaster validation and post-operation handling
- Edge cases (insufficient balances, unauthorized callers)

# Security Considerations
- **Access Control**: Uses OpenZeppelin’s Ownable for admin functions and restricts sensitive operations to authorized callers.
- **Reentrancy Protection**: Implements ReentrancyGuard to prevent reentrancy attacks.
- **Gas Limits**: Conservative gas estimation to ensure sufficient coverage for operations.
- **Emergency Functions**: Includes `emergencyWithdrawUsdc` and `emergencyWithdrawEth` for owner-controlled recovery.

# Future Improvements
- Integrate Chainlink for real-time USDC/ETH price feeds.
- Support additional stablecoins (e.g., DAI, USDT).
- Enhance gas estimation with dynamic profiling based on transaction complexity.
- Add multi-network support for broader Circle Paymaster compatibility.

# Circle Paymaster Addresses
- **Arbitrum Mainnet**: 0x6C973eBe80dCD8660841D4356bf15c32460271C9
- **Arbitrum Testnet**: 0x31BE08D380A21fc740883c0BC434FcFc88740b58
- **Base Mainnet**: 0x6C973eBe80dCD8660841D4356bf15c32460271C9
- **Base Testnet**: 0x31BE08D380A21fc740883c0BC434FcFc88740b58

# License
This project is licensed under the MIT License. See the SPDX-License-Identifier: MIT in the contract files.

# Acknowledgements
- Uniswap V4 for the hook architecture and core/periphery libraries.
- Circle for the ERC-4337 Paymaster service.
- OpenZeppelin for secure contract primitives.



