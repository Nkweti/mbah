import { ethers } from "hardhat";

async function main() {
  console.log("Starting deployment...");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

  // Set up signers for MyToken (you can change these addresses as needed)
  const mintSigners: [string, string, string] = [
    "0x1234567890123456789012345678901234567890", // Replace with actual addresses
    "0x2345678901234567890123456789012345678901", // Replace with actual addresses
    "0x3456789012345678901234567890123456789012"  // Replace with actual addresses
  ];
  
  const withdrawSigners: [string, string, string] = [
    "0x1234567890123456789012345678901234567890", //  actual addresses
    "0x2345678901234567890123456789012345678901", //  actual addresses
    "0x3456789012345678901234567890123456789012"  //  actual addresses
  ];

  // Deploy MyToken 
  console.log("\n--- Deploying MyToken ---");
  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy(
    "University of Bamenda Token", // name
    "G3TK",                      // symbol
    mintSigners,                // mint signers
    withdrawSigners,            // withdraw signers
    ethers.parseUnits("1000000", 18) // initial supply (1M tokens)
  );

  await myToken.waitForDeployment();
  console.log("MyToken deployed to:", await myToken.getAddress());
  console.log("Token name:", await myToken.name());
  console.log("Token symbol:", await myToken.symbol());
  console.log("Total supply:", (await myToken.totalSupply()).toString());

  // Deploy UBaEducationCredentialsStore
  console.log("\n--- Deploying UBaEducationCredentialsStore ---");
  const verificationFee = ethers.parseUnits("10", 18); // 10 tokens for verification
  
  const CredentialsStore = await ethers.getContractFactory("UBaEducationCredentialsStore");
  const credentialsStore = await CredentialsStore.deploy(
    await myToken.getAddress(), // token contract address
    verificationFee             // verification fee
  );

  await credentialsStore.waitForDeployment();
  console.log("UBaEducationCredentialsStore deployed to:", await credentialsStore.getAddress());
  console.log("Verification fee:", verificationFee.toString());

  // Store deployment info
  console.log("\n--- Deployment Summary ---");
  console.log("Network:", await ethers.provider.getNetwork());
  console.log("Deployer:", deployer.address);
  console.log("MyToken address:", await myToken.getAddress());
  console.log("CredentialsStore address:", await credentialsStore.getAddress());
  
  // Verifying contracts on Etherscan (if you have the verification plugin)
  console.log("\n--- Contract Verification ---");
  console.log("To verify MyToken on Etherscan:");
  console.log(`npx hardhat verify --network sepolia ${await myToken.getAddress()} "University of Buea Token" "UBT" "[${mintSigners.join(',')}]" "[${withdrawSigners.join(',')}]" "${ethers.parseUnits("1000000", 18)}"`);
  
  console.log("\nTo verify CredentialsStore on Etherscan:");
  console.log(`npx hardhat verify --network sepolia ${await credentialsStore.getAddress()} ${await myToken.getAddress()} ${verificationFee}`);

  console.log("\n Deployment completed successfully!");
}

// Error handling
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(" Deployment failed:");
    console.error(error);
    process.exit(1);
  }); 
