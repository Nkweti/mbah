 
# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

##Install required VS Code extensions:

 Hardhat for Visual Studio Code

 Solidity extension (Juan Blanco)

 Prettier (for formatting)

 GitLens (optional for Git integration)
 # Try running some of the following tasks:

```shell
npx hardhat help

```
##creating hardhat project
# Create project directory
mkdir blockchain-project
cd blockchain-project

# Initialize Hardhat project
npm init -y
npm install --save-dev hardhat
npx hardhat
# Install suggested dependencies when prompted
Install Dependencies
# OpenZeppelin contracts
npm install @openzeppelin/contracts

# Testing and development dependencies
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install --save-dev @nomiclabs/hardhat-ethers
npm install --save-dev @nomiclabs/hardhat-etherscan
npm install --save-dev dotenv
# Configure Environment Variables
.env file holds the Alchemy URL, PRIVATE KEY, EtherScan key
hardhat.config.ts - main confuration of hardhat to use sepolia network using .env file content 
# Create MyToken.sol Contract
contracts/MyToken.sol:
# Create UBaEducationCredentialsStore.sol
contracts/UBaEducationCredentialsStore.sol
# compile hardhat 
npx hardhat compile
#  Create Deployment Scripts
scripts/deploy.ts
# Create Comprehensive Tests
test/MyToken.test.ts
# run testing 
npx hardhat test
# run deploy 
npx hardhat run scripts/deploy.ts --network sepolia
# Verify MyToken
npx hardhat verify --network sepolia CONTRACT_ADDRESS "Group X Token" "GXTK" "[\"0x...\",\"0x...\",\"0x...\"]" "[\"0x...\",\"0x...\",\"0x...\"]" 1000000

# Verify CredentialsStore
npx hardhat verify --network sepolia CONTRACT_ADDRESS TOKEN_ADDRESS VERIFICATION_FEE
# Create Transfer Tokens
 scripts/transfer.ts

## Security Considerations Implemented

1. **ReentrancyGuard**: Prevents reentrancy attacks
2. **Multi-signature**: Requires multiple approvals for critical operations
3. **Access Control**: Proper permission checks
4. **Input Validation**: Thorough parameter validation
5. **Event Logging**: Comprehensive event emission for transparency

## Why Store Hashes Instead of Plaintext Credentials

1. **Privacy Protection**: Sensitive information is not exposed on the public blockchain
2. **Storage Efficiency**: Hashes are fixed-size (32 bytes) regardless of document size, reducing gas costs
