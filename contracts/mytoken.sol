// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MyToken is ERC20, Ownable, ReentrancyGuard {
    // Multi-signature addresses for minting (3 required)
    address[3] public mintSigners;
    mapping(address => mapping(uint256 => bool)) public mintApprovals;
    uint256 public mintNonce;
    
    // Multi-signature addresses for withdrawal (2 out of 3 required)
    address[3] public withdrawSigners;
    mapping(address => mapping(uint256 => bool)) public withdrawApprovals;
    uint256 public withdrawNonce;
    
    // Token price in wei (1 ETH = 1000 tokens)
    uint256 public constant TOKEN_PRICE = 1e15; // 0.001 ETH per token
    
    // Events
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 ethSpent);
    event MintRequested(uint256 indexed nonce, address indexed to, uint256 amount);
    event MintApproved(uint256 indexed nonce, address indexed signer);
    event TokensMinted(uint256 indexed nonce, address indexed to, uint256 amount);
    event WithdrawRequested(uint256 indexed nonce, uint256 amount);
    event WithdrawApproved(uint256 indexed nonce, address indexed signer);
    event FundsWithdrawn(uint256 indexed nonce, uint256 amount);
    
    constructor(
        string memory name,
        string memory symbol,
        address[3] memory _mintSigners,
        address[3] memory _withdrawSigners,
        uint256 _initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        require(_mintSigners[0] != address(0) && _mintSigners[1] != address(0) && _mintSigners[2] != address(0), "Invalid mint signers");
        require(_withdrawSigners[0] != address(0) && _withdrawSigners[1] != address(0) && _withdrawSigners[2] != address(0), "Invalid withdraw signers");
        
        mintSigners = _mintSigners;
        withdrawSigners = _withdrawSigners;
        
        if (_initialSupply > 0) {
            _mint(msg.sender, _initialSupply * 10**decimals());
        }
    }
    
    // Modifier to check if sender is a mint signer
    modifier onlyMintSigner() {
        require(
            msg.sender == mintSigners[0] || 
            msg.sender == mintSigners[1] || 
            msg.sender == mintSigners[2], 
            "Not a mint signer"
        );
        _;
    }
    
    // Modifier to check if sender is a withdraw signer
    modifier onlyWithdrawSigner() {
        require(
            msg.sender == withdrawSigners[0] || 
            msg.sender == withdrawSigners[1] || 
            msg.sender == withdrawSigners[2], 
            "Not a withdraw signer"
        );
        _;
    }
    
    // Receive function to allow ETH-to-token conversion
    receive() external payable {
        require(msg.value > 0, "Must send ETH");
        _buyTokens();
    }
    
    // Buy tokens with ETH
    function buyTokens() external payable {
        require(msg.value > 0, "Must send ETH");
        _buyTokens();
    }
    
    // Internal function to handle token purchase
    function _buyTokens() internal nonReentrant {
        uint256 tokenAmount = (msg.value * 10**decimals()) / TOKEN_PRICE;
        require(tokenAmount > 0, "Insufficient ETH for tokens");
        
        _mint(msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
    }
    
    // Request minting (requires multi-signature approval)
    function requestMint(address to, uint256 amount) external onlyMintSigner {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be positive");
        
        uint256 currentNonce = mintNonce++;
        emit MintRequested(currentNonce, to, amount);
    }
    
    // Approve minting
    function approveMint(uint256 nonce, address to, uint256 amount) external onlyMintSigner {
        require(!mintApprovals[msg.sender][nonce], "Already approved");
        
        mintApprovals[msg.sender][nonce] = true;
        emit MintApproved(nonce, msg.sender);
        
        // Check if we have 3 approvals
        if (_getMintApprovalCount(nonce) >= 3) {
            _mint(to, amount);
            emit TokensMinted(nonce, to, amount);
        }
    }
    
    // Get mint approval count
    function _getMintApprovalCount(uint256 nonce) internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (mintApprovals[mintSigners[i]][nonce]) {
                count++;
            }
        }
        return count;
    }
    
    // Request withdrawal (requires 2 out of 3 signatures)
    function requestWithdraw(uint256 amount) external onlyWithdrawSigner {
        require(amount > 0, "Amount must be positive");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        uint256 currentNonce = withdrawNonce++;
        emit WithdrawRequested(currentNonce, amount);
    }
    
    // Approve withdrawal
    function approveWithdraw(uint256 nonce, uint256 amount) external onlyWithdrawSigner {
        require(!withdrawApprovals[msg.sender][nonce], "Already approved");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        withdrawApprovals[msg.sender][nonce] = true;
        emit WithdrawApproved(nonce, msg.sender);
        
        // Check if we have 2 approvals
        if (_getWithdrawApprovalCount(nonce) >= 2) {
            payable(owner()).transfer(amount);
            emit FundsWithdrawn(nonce, amount);
        }
    }
    
    // Get withdraw approval count
    function _getWithdrawApprovalCount(uint256 nonce) internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (withdrawApprovals[withdrawSigners[i]][nonce]) {
                count++;
            }
        }
        return count;
    }
    
    // Geting contract ETH balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Geting token price
    function getTokenPrice() external pure returns (uint256) {
        return TOKEN_PRICE;
    }
} 
