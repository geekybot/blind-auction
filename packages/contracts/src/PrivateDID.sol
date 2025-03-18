// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;

contract PrivateDID {
    address public owner;

    /// @title PrivateDID
    /// @author Anonymous
    /// @notice A contract for managing private decentralized identifiers (DIDs) with secure authentication
    /// @dev Uses suint256 and saddress types for private data storage and verification
    /// @custom:security Ensures only authorized parties can create and verify DIDs
    struct ID {
        suint256 phone;
        suint256 idProof;
        saddress primaryAddress;
        suint256 secretAuthCode;
    }


    mapping(saddress => bytes32) id;
    mapping(address => mapping(address => bool)) public activeStatus;
    mapping(address => bool) public protocolRegistered;

    // Constructor to initialize set the Gov Administrator
    constructor() {
        owner = msg.sender;
    }

    
    /// @notice Creates a new decentralized identifier (DID) for a user.
    /// @param _phone The user's phone number.
    /// @param _idProof The user's identification proof.
    /// @param _user The user's on-chain address.
    /// @param _secretAuthCode A secret authentication code for the user.
    /// @dev This function can only be called by the contract owner.
    function createDID(
        suint256 _phone,
        suint256 _idProof,
        saddress _user,
        suint256 _secretAuthCode
    ) external onlyOwner {
        bytes32 generatedId = keccak256(
            abi.encodePacked(_phone, _idProof, _user, _secretAuthCode)
        );
        id[_user] = generatedId;
    }

    /// @notice Registers the calling address as a protocol participant.
    /// @dev This function allows the caller to register their address in the protocol.
    function registerProtocol() public {
        protocolRegistered[msg.sender] = true;
    }

    /// @notice Registers the user's authentication information.
    /// @param _phone The user's phone number.
    /// @param _idProof The user's identification proof.
    /// @param _user The user's on-chain address.
    /// @param _secretAuthCode A secret authentication code for the user.
    /// @param _authority An address that is verified by the DID and authenticated
    /// @dev This function verifies that the user has a DID and marks the caller's address as active in the protocol.
    function registerAuth(
        suint256 _phone,
        suint256 _idProof,
        saddress _user,
        suint256 _secretAuthCode,
        address _authority
    ) public onlyProtocol {
        bytes32 generatedId = keccak256(
            abi.encodePacked(_phone, _idProof, _user, _secretAuthCode)
        );
        require(generatedId == id[_user], "USER_DOESN'T_HAVE_DID");
        activeStatus[msg.sender][_authority] = true;
    }

    /// @notice Checks if the caller is authenticated by a specific authority.
    /// @param _authority The address of the authority to check authentication against.
    /// @return authenticated A boolean indicating whether the caller is authenticated by the specified authority.
    function isAuthenticated(
        address _authority
    ) public view returns (bool authenticated) {
        authenticated = activeStatus[msg.sender][_authority];
    }

    /// @notice Retrieves the Keccak ID associated with a specific user.
    /// @param _user The user's on-chain address for which the ID is being retrieved.
    /// @return _id The Keccak ID associated with the specified user.
    function getKeccakID(
        saddress _user
    ) public view returns (bytes32 _id) {
        _id = id[_user];
    }

    //Modifier who can call the specific privilaged functions
    modifier onlyOwner() {
        require(msg.sender == owner, 'CALLER_IS_NOT_THE_OWNER');
        _;
    }

    // Modifier to check if the caller is a registered protocol participant
    modifier onlyProtocol() {
        require(
            protocolRegistered[msg.sender],
            'CALLER_IS_NOT_A_REGISTERED_PROTOCOL'
        );
        _;
    }
}
