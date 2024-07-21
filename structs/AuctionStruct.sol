// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

enum AuctionState {
    Upcoming,
    Live,
    Completed,
    Cancelled
}

struct UniqueAuctionInfo {
    string title;
    string termsAndConditions;
    string auctionInformation;
    uint participantCount;
    uint playsConsumedPerBid;
    uint registrationFees;
    uint totalBids;
    uint8 decimalCount;
    bool registration;
}

struct EditUniqueAuction {
    string title;
    string termsAndConditions;
    string auctionInformation;
    uint participantCount;
    uint totalBids;
    uint8 decimalCount;
}

struct TheLastPlayAuctionInfo {
    string title;
    string termsAndConditions;
    string auctionInformation;
    uint participantCount;
    uint playsConsumedPerBid;
    uint registrationFees;
    bool registration;
}

struct EditLastPlayAuction {
    string title;
    string termsAndConditions;
    string auctionInformation;
    uint participantCount;
}
