// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EnerZ.sol";
import "./Groth16Verifier.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Exchange is ReentrancyGuard {
    EnerZ public token;
    IERC20 public paymentToken; // Token usado para pagamento (ex: USDC, DAI)
    Groth16Verifier public verifier;

    mapping(address => uint256) public balances;
    
    struct Listing {
        address seller;
        uint256 amount;
        uint256 price;
        bool isActive;
    }
    
    uint256 public listingId;
    mapping(uint256 => Listing) public listings;
    
    event ListingCreated(uint256 indexed listingId, address indexed seller, uint256 amount, uint256 price);
    event ListingSold(uint256 indexed listingId, address indexed buyer, address indexed seller, uint256 amount, uint256 price);
    event ListingCancelled(uint256 indexed listingId, address indexed seller);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address tokenAddress, address paymentTokenAddress, address verifierAddress) {
        token = EnerZ(tokenAddress);
        paymentToken = IERC20(paymentTokenAddress);
        verifier = Groth16Verifier(verifierAddress);
    }

    function deposit(uint256 amount) external nonReentrant {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // 🔐 Verifica prova de que saldo é >= a certo limite sem revelar o saldo real
    function verifyBalanceProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input // public input = threshold
    ) public view returns (bool) {
        return verifier.verifyProof(a, b, c, input);
    }

    function createListing(uint256 amount, uint256 price) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(price > 0, "Price must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        listingId++;
        listings[listingId] = Listing({
            seller: msg.sender,
            amount: amount,
            price: price,
            isActive: true
        });
        
        emit ListingCreated(listingId, msg.sender, amount, price);
    }
    
    function buyListing(uint256 _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing is not active");
        
        // Transferir tokens de pagamento do comprador para o contrato
        require(paymentToken.transferFrom(msg.sender, address(this), listing.price), "Payment transfer failed");
        
        listing.isActive = false;
        
        // Transferir tokens EnerZ para o comprador
        require(token.transfer(msg.sender, listing.amount), "Token transfer failed");
        
        // Transferir tokens de pagamento para o vendedor
        require(paymentToken.transfer(listing.seller, listing.price), "Payment transfer failed");
        
        emit ListingSold(_listingId, msg.sender, listing.seller, listing.amount, listing.price);
    }
    
    function cancelListing(uint256 _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing is not active");
        require(listing.seller == msg.sender, "Not the seller");
        
        listing.isActive = false;
        require(token.transfer(msg.sender, listing.amount), "Token transfer failed");
        
        emit ListingCancelled(_listingId, msg.sender);
    }
    
    function getActiveListings() external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 1; i <= listingId; i++) {
            if (listings[i].isActive) {
                count++;
            }
        }
        
        uint256[] memory activeListings = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= listingId; i++) {
            if (listings[i].isActive) {
                activeListings[index] = i;
                index++;
            }
        }
        
        return activeListings;
    }
}
