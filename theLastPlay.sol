// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./BaseAuction.sol";

/**
 * @title TheLastPlay
 * @dev Contract for managing "The Last Play" auction.
 */
contract TheLastPlay is BaseAuction {
    /**
     * @dev Constructor to initialize "The Last Play" auction.
     * @param _owner The address of the auction owner.
     * @param _product The product details for the auction.
     * @param _auction The "The Last Play" auction details.
     */
    constructor(
        address _owner,
        ProductStruct memory _product,
        TheLastPlayAuctionInfo memory _auction,
        AuctionHouseDetails memory _auctionHouseDetails
    ) BaseAuction(_owner) {
        _setAuctionHouseDetails(address(this), _auctionHouseDetails);
        _setProductAndAuctionType(
            _product,
            AuctionTypeStruct({title: "The Last Play"})
        );

        auctionTitle = _auction.title;
        registrationRequired = _auction.registration;
        participantCount = _auction.participantCount;
        playsConsumedPerBid = _auction.playsConsumedPerBid;
        registrationFees = _auction.registrationFees;
        termsAndConditions = _auction.termsAndConditions;
        auctionInformation = _auction.auctionInformation;
        state = AuctionState.Upcoming;
    }

    event AuctionEdited();

    /**
     * @notice Edits the details of the auction.
     * @dev Can only be called by the owner when the auction is not deleted and is upcoming.
     * @param auction The new auction details to be set.
     * @param _auctionType The type of the auction.
     */
    function editAuction(
        EditLastPlayAuction memory auction,
        AuctionTypeStruct memory _auctionType
    ) external isNotDeleted isUpcoming onlyOwner {
        _editAuctionCommonFields(
            auction.title,
            auction.participantCount,
            auction.termsAndConditions,
            auction.auctionInformation,
            _auctionType
        );

        emit AuctionEdited();
    }
}
