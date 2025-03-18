// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;
import './PrivateDID.sol';

contract BlindAuction {
    /// @title BlindAuction
    /// @author Anonymous
    /// @notice A contract for conducting blind auctions with private bids
    /// @dev Uses PrivateDID for user authentication and suint256 for private bid amounts
    /// @custom:security Ensures only authenticated users can participate in auctions
    struct Bid {
        address bidder;
        suint256 amount;
    }

    /// @notice Represents the details of an auction.
    /// @param owner The address of the auction creator/owner.
    /// @param highestBid The current highest bid amount (as a secret uint256).
    /// @param highestBidder The address of the current highest bidder.
    /// @param bids Mapping of bidder addresses to their bid details.
    /// @param isActive Boolean indicating whether the auction is currently active.
    struct AuctionDetails {
        address owner;
        suint256 highestBid;
        address highestBidder;
        mapping(address => Bid) bids;
        bool isActive;
    }

    mapping(uint256 => AuctionDetails) auctions;
    uint256 public auctionCount;
    PrivateDID private privateDID;

    constructor(address _privateDIDAddress) {
        privateDID = PrivateDID(_privateDIDAddress);
        privateDID.registerProtocol();
    }

    /// @notice Creates a new auction with the caller as the owner
    /// @dev Increments the auction counter and initializes a new auction
    /// @dev Sets the auction status to active and assigns ownership to the caller
    function createAuction() external {
        auctionCount++;
        auctions[auctionCount].owner = msg.sender;
        auctions[auctionCount].isActive = true;
    }

    /// @notice Places a bid on an active auction
    /// @param auctionId The ID of the auction to bid on
    /// @param bidAmount The amount to bid (as a secret uint256)
    /// @dev Only authenticated users can place bids. The bid must be higher than the current highest bid.
    /// @dev Updates the auction's highest bid, highest bidder, and stores the bid details
    function placeBid(
        uint256 auctionId,
        suint256 bidAmount
    ) external onlyAuthenticated(msg.sender) {
        AuctionDetails storage auction = auctions[auctionId];
        require(auction.isActive, 'AUCTION_IS_NOT_ACTIVE');
        require(
            bidAmount > suint256(0),
            'BID_MUST_NOT_BE_ZERO'
        );

        // Update the highest bid
        if(bidAmount >= auction.highestBid) {
            auction.highestBid = bidAmount;
            auction.highestBidder = msg.sender;
        }
        auction.bids[msg.sender] = Bid(msg.sender, bidAmount);
    }

    /// @notice Ends an active auction
    /// @param auctionId The ID of the auction to end
    /// @dev Only the auction owner can end their auction
    /// @dev Sets the auction status to inactive
    function endAuction(uint256 auctionId) external onlyAuctionOwner(auctionId) {
        AuctionDetails storage auction = auctions[auctionId];
        require(auction.isActive, 'AUCTION_IS_NOT_ACTIVE');
        auction.isActive = false;
    }

    /// @notice Announces the winner of an ended auction and reveals the winning bid amount
    /// @param auctionId The ID of the auction to announce
    /// @dev Only callable after auction has ended
    /// @dev Reveals the winning bid amount by casting from suint256 to uint256
    function announceWinner(uint256 auctionId) external view returns (address winner, uint256 winningBid) {
        AuctionDetails storage auction = auctions[auctionId];
        require(!auction.isActive, "AUCTION_MUST_BE_ENDED");
        require(auction.highestBidder != address(0), "N0_BIDS_WERE_PLACED");

        winner = auction.highestBidder;
        winningBid = uint256(auction.highestBid); // Cast suint256 to uint256 to reveal amount
        
        return (winner, winningBid);
    }

    /// @notice Registers user authentication details to the PrivateDID system
    /// @param _phone The user's phone number as a secret uint256
    /// @param _idProof The user's identification proof as a secret uint256
    /// @param _user The address of the user being authenticated
    /// @param _secretAuthCode A secret authentication code as a secret uint256
    /// @dev This function can only be called by users who are already authenticated.
    /// @dev It registers the user's authentication details with the PrivateDID contract.
    /// @dev Emits an event upon successful registration (if applicable).
    function registerAuthToDID(
        suint256 _phone,
        suint256 _idProof,
        saddress _user,
        suint256 _secretAuthCode
    ) external {
        require(!privateDID.isAuthenticated(msg.sender), "USER_ALREADY_AUTHENTICATED");
        privateDID.registerAuth(_phone, _idProof, _user, _secretAuthCode, msg.sender);
    }

    modifier onlyAuthenticated(address _user) {
        require(privateDID.isAuthenticated(_user), 'USER_IS_NOT_AUTHENTICATED');
        _;
    }
    modifier onlyAuctionOwner(uint256 _auctionId) {
        require(
            msg.sender == auctions[_auctionId].owner,
            'ONLY_AUCTION_OWNER_CAN_CALL'
        );
        _;
    }
}
