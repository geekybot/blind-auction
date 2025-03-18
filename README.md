
# PrivateDID and BlindAuction Overview

  

## Table of Contents

1. [Introduction](#introduction)

2. [PrivateDID](#privatedid)

- [Features](#privatedid-features)

- [User Workflow](#privatedid-user-workflow)

3. [BlindAuction](#blindaunction)

- [Features](#blindaunction-features)

- [User Workflow](#blindaunction-user-workflow)

4. [Conclusion](#conclusion)

5. [Required tools and Installation guides](#required-tools-and-installation-guides)
6. [Test](#test)

  

## Introduction

This is a demo project using [seismicvm's](https://docs.seismic.systems/introduction/how) shielded type `(stype)` parameters to hide certain parameter's to keep confidentiality of blind auction while keeping the integrity of the identifying the bidder in a blind auction. This project has two different smart contracts, `PrivateDID` can be used in any other contract as well, to implement DID functionalities. `BlindAuction` showcases the power of the `stype` parameters as hidden input in execution.  
  

## PrivateDID

  

### Features

-  **Create DID**: This feature can be called by the owner `(read auth provider)` upon verifying the user's identity offchain and recording their identifying attributes on chain but in secret.
        ```bash
        suint256 _phone,
        suint256 _idProof,
        saddress _user,
        suint256 _secretAuthCode.
        ``` 
These attributes will remain hidden during execution, and later will be required to verify the auth by the user.
		

-  **Register Protocol**: A protocol `("BlindAuction" in our example)` should register itself to the `PrivateDID` contract to use these auth features.

-  **Register Auth**: Let's user register themselves to use a protocol via an authority signer, by registering themselves from the protocol to the `PrivateDID` contract. Then authority signer can be used to perform actions on the protocol contract.

  

<!-- ### User Workflow

1.  **Step 1**: Description of the first step in the user workflow.

2.  **Step 2**: Description of the second step in the user workflow.

3.  **Step 3**: Description of the third step in the user workflow.

   -->

## BlindAuction

  

### Features

-  **Create Auction**: Let's anyone create auction on the `BlindAuction` contract.

-  **Register Auth To DID**: Register a signer `authority` to prove to be an authorized signer and allow access to the signer to participate in auction.

-  **Place Bid**: An authorized signer can place bid, the bid amount is `suint256` or shielded parameter, which is hidden during execution and storing, upon ending the auction, this can be revealed.

-  **End Auction**: Owner of the auction can end the auction, then the result is revealed. The highest bidder and their `bidAmound` is revealed.

- **Announce Winner**: After the `endAuction` function is called this function will reveal the winner and their `bidAmount`.

  

### User Workflow

1.  **Step 1**: `createDID` to register for a private ID.

2.  **Step 2**: `registerAuthToDID` to register auth signatory, upon proving their credentials to the `PrivateDID` contract, then the auth signer will be able to participate in the auction contract.

3.  **Step 3**: `placeBid` bid for the blind auction with a hidden `bidding amount`.

  

## Conclusion

This repo demonstrates the awesome functionlaities of [Seismic](https://seismic.systems) blockchain and their powerful stypes. 

## Required tools and Installation guides 
This projects require `sforge` `sanvil` and `ssolc` to compile and test.
Follow the [Installation Guide](https://docs.seismic.systems/onboarding/publish-your-docs) for these tools.

## Test
Navigate to `packages/contracts` then 
run ```forge build``` and ```forge test -vvv```