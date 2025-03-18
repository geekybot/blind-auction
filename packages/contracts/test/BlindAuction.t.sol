// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BlindAuction.sol";
import "../src/PrivateDID.sol";


contract BlindAuctionTest is Test {
    BlindAuction auction;
    PrivateDID private didContract;


    address bidder1 = address(0x678);
    address bidder2 = address(0x987);
    // address constant public DID = address(0x39876);
    function setUp() public {
        didContract = new PrivateDID();
        auction = new BlindAuction(address(didContract));
        
    }

    function test_StartAuction() public {
        address auctionOwner1 = address(0x667);
        vm.prank(auctionOwner1);
        auction.createAuction();
        vm.stopPrank();
        assertEq(didContract.protocolRegistered(address(auction)), true);
        assertEq(auction.auctionCount(), 1);
        // Add assertions to check auction state
    }

    function test_RegisterAuthToDID() public {
        suint256 phone = suint256(1234567890);
        suint256 idProof = suint256(9876543210);
        suint256 secretAuthCode = suint256(1111);

        didContract.createDID(phone, idProof, saddress(bidder1), secretAuthCode);

        // Check that the DID was created correctly
        suint256 fake_secretAuthCode = suint256(1121);

        bytes32 expectedId = keccak256(abi.encodePacked(phone, idProof, bidder1, secretAuthCode));
        // vm.Log(expectedId);
        assertEq(didContract.getKeccakID(saddress(bidder1)), expectedId);
        assertFalse(didContract.isAuthenticated(bidder1));
        vm.prank(bidder2);
        // assertFalse(didContract.isAuthenticated(bidder2));
        // vm.expectRevert("USER_DOESN'T_HAVE_DID");
        auction.registerAuthToDID(phone, idProof, saddress(bidder1), secretAuthCode);
        // auction.registerAuthToDID(phone, idProof, saddress(bidder1), secretAuthCode);
        vm.stopPrank();
        
        // assertTrue(didContract.isAuthenticated(bidder2));

        // vm.expectRevert("USER_DOESN'T_HAVE_DID");
        // auction.registerAuthToDID(phone, idProof, saddress(bidder1), secretAuthCode);
        // vm.stopPrank();
        // assertEq(didContract.isAuthenticated(bidder2), true);
    }

    function test_Bid() public {
        test_StartAuction();
        test_RegisterAuthToDID();
        assertEq(auction.auctionCount(), 1);
        vm.prank(bidder2);
        auction.placeBid(1, suint256(100));
        test_MultipleBids();
    }

    function test_RevealBid() public {
        // test_Bid();
        
        test_EndAuction();
        (address winner, uint256 winningBid) = auction.announceWinner(1);
        emit log_named_address("Winner Address", winner);
        emit log_named_uint("Winning Bid", winningBid);
    }

    function test_EndAuction() public {
        test_Bid();
        address auctionOwner1 = address(0x667);
        vm.prank(auctionOwner1);
        auction.endAuction(1);
        // Add assertions to check auction ended state
    }


    function test_Register_ThreeBidderAndCreateThreeBids() public {
        // Create three bidders
        address bidder1 = address(0x678);
        address bidder4 = address(0x999);
        address bidder3 = address(0x456);

        // Create DIDs for each bidder
        suint256 phone1 = suint256(1234567890);
        suint256 idProof1 = suint256(1111111111);
        suint256 secretAuthCode1 = suint256(1111);

        suint256 phone2 = suint256(2234567890);
        suint256 idProof2 = suint256(2222222222);
        suint256 secretAuthCode2 = suint256(2222);

        suint256 phone3 = suint256(3234567890);
        suint256 idProof3 = suint256(3333333333);
        suint256 secretAuthCode3 = suint256(3333);

        // Create DIDs
        didContract.createDID(phone1, idProof1, saddress(bidder1), secretAuthCode1);
        didContract.createDID(phone2, idProof2, saddress(bidder4), secretAuthCode2);
        didContract.createDID(phone3, idProof3, saddress(bidder3), secretAuthCode3);

        // Authenticate each bidder for the auction
        vm.prank(bidder1);
        auction.registerAuthToDID(phone1, idProof1, saddress(bidder1), secretAuthCode1);

        vm.prank(bidder4);
        auction.registerAuthToDID(phone2, idProof2, saddress(bidder4), secretAuthCode2);

        vm.prank(bidder3);
        auction.registerAuthToDID(phone3, idProof3, saddress(bidder3), secretAuthCode3);

        // Add assertions to check that each bidder is authenticated
        // assertTrue(didContract.isAuthenticated(bidder1));
        // assertTrue(didContract.isAuthenticated(bidder2));
        // assertTrue(didContract.isAuthenticated(bidder3));
    }

    function test_MultipleBids() private {
        // Create three bidders
        address bidder1 = address(0x678);
        address bidder4 = address(0x999);
        address bidder3 = address(0x456);

        // Create DIDs and authenticate them (assuming this is already done in the previous test)
        test_Register_ThreeBidderAndCreateThreeBids();

        // Place bids from each bidder
        vm.prank(bidder1);
        auction.placeBid(1, suint256(190)); // Bid from bidder1

        vm.prank(bidder4);
        auction.placeBid(1, suint256(200)); // Bid from bidder2

        vm.prank(bidder3);
        auction.placeBid(1, suint256(250)); // Bid from bidder3

    }
    // Additional tests for edge cases and failure scenarios
}
