// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract UBaEducationCredentialsStore is Ownable, ReentrancyGuard {
    IERC20 public paymentToken;
    uint256 public verificationFee;
    
    // Mapping from document hash to verification status
    mapping(bytes32 => bool) public credentialExists;
    mapping(bytes32 => uint256) public credentialTimestamp;
    mapping(bytes32 => address) public credentialOwner;
    
    // Events
    event CredentialStored(
        bytes32 indexed documentHash,
        address indexed owner,
        uint256 timestamp
    );
    
    event CredentialVerified(
        bytes32 indexed documentHash,
        address indexed verifier,
        uint256 fee,
        bool exists
    );
    
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    
    constructor(
        address _paymentToken,
        uint256 _verificationFee
    ) Ownable(msg.sender) {
        require(_paymentToken != address(0), "Invalid token address");
        paymentToken = IERC20(_paymentToken);
        verificationFee = _verificationFee;
    }
    
    /**
     * Store credential hash on blockchain
    
     */
    function storeCredential(string memory credentialJson) external onlyOwner {
        bytes32 documentHash = keccak256(abi.encodePacked(credentialJson));
        require(!credentialExists[documentHash], "Credential already exists");
        
        credentialExists[documentHash] = true;
        credentialTimestamp[documentHash] = block.timestamp;
        credentialOwner[documentHash] = msg.sender;
        
        emit CredentialStored(documentHash, msg.sender, block.timestamp);
    }
    
    /**
     * Verify credential by paying tokens
     * Users pay tokens to verify if a credential exists
     */
    function verifyCredential(string memory credentialJson) external nonReentrant {
        require(verificationFee > 0, "Verification fee not set");
        
        // Transfer tokens from user to contract
        require(
            paymentToken.transferFrom(msg.sender, address(this), verificationFee),
            "Token transfer failed"
        );
        
        bytes32 documentHash = keccak256(abi.encodePacked(credentialJson));
        bool exists = credentialExists[documentHash];
        
        emit CredentialVerified(documentHash, msg.sender, verificationFee, exists);
    }
    
   
    
    function getCredentialStatus(string memory credentialJson) 
        external 
        view 
        returns (bool exists, uint256 timestamp, address owner) 
    {
        bytes32 documentHash = keccak256(abi.encodePacked(credentialJson));
        return (
            credentialExists[documentHash],
            credentialTimestamp[documentHash],
            credentialOwner[documentHash]
        );
    }
    
    /**
     * Update verification fee (only owner)
     */
    function updateVerificationFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = verificationFee;
        verificationFee = _newFee;
        emit FeeUpdated(oldFee, _newFee);
    }
    
    /**
     * Withdraw collected tokens (only owner)
     */
    function withdrawTokens() external onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        require(paymentToken.transfer(owner(), balance), "Token transfer failed");
        emit TokensWithdrawn(owner(), balance);
    }
    
    /**
     * Get contract token balance
     */
    function getContractTokenBalance() external view returns (uint256) {
        return paymentToken.balanceOf(address(this));
    }
    
    /**
     * Get payment token address
     */
    function getPaymentToken() external view returns (address) {
        return address(paymentToken);
    }
}