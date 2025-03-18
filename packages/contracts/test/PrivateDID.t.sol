// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/PrivateDID.sol";

contract PrivateDIDTest is Test {
    PrivateDID private didContract;
    address private owner;
    saddress private user;

    function setUp() public {
        owner = address(this);
        user = saddress(0x123);
        didContract = new PrivateDID();
    }

    function test_CreateDID() public {
        suint256 phone = suint256(1234567890);
        suint256 idProof = suint256(9876543210);
        suint256 secretAuthCode = suint256(1111);

        didContract.createDID(phone, idProof, user, secretAuthCode);

        // Check that the DID was created correctly
        bytes32 expectedId = keccak256(abi.encodePacked(phone, idProof, user, secretAuthCode));
        // vm.Log(expectedId);
        assertEq(didContract.getKeccakID(user), expectedId);
    }

    function test_OnlyOwnerCanCreateDID() public {
        // Attempt to create a DID from a non-owner address
        vm.prank(address(0x123)); // Simulate a call from the user address
        suint256 phone = suint256(1234567890);
        suint256 idProof = suint256(9876543210);
        suint256 secretAuthCode = suint256(1111);

        vm.expectRevert("CALLER_IS_NOT_THE_OWNER");
        didContract.createDID(phone, idProof, user, secretAuthCode);
    }

    function test_ProtocolNotRegistered() public {
        assertEq(didContract.protocolRegistered(address(0x234)), false);
    }
    function test_RegisterProtocol() public {
        address protocol = address(0x2344);
        vm.prank(protocol);
        didContract.registerProtocol();
        assertEq(didContract.protocolRegistered(protocol), true);
    }
    function test_RegisterAuth() public {
        // Set up test data
        suint256 phone = suint256(1234567890);
        suint256 idProof = suint256(9876543210);
        suint256 secretAuthCode = suint256(1111);
        address authority = address(0x345);
        address protocol = address(0x234);

        // First create the DID as owner
        didContract.createDID(phone, idProof, user, secretAuthCode);

        // Register protocol
        vm.startPrank(protocol);
        didContract.registerProtocol();
        didContract.registerAuth(phone, idProof, user, secretAuthCode, authority);

        // Try to register auth with fake secret auth, wrong credentials
        suint256 fake_secretAuthCode = suint(2222);
        vm.expectRevert("USER_DOESN'T_HAVE_DID");
        didContract.registerAuth(phone, idProof, user, fake_secretAuthCode, authority);
        vm.stopPrank();

        address protocol2 = address(0x4456);
        // Verify auth was registered
        vm.prank(protocol);
        assertTrue(didContract.isAuthenticated(authority));
    }

    // Additional tests for edge cases and failure scenarios
}
