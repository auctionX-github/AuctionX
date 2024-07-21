// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./BaseAuction.sol";

/**
 * @title UniqueAuction
 * @dev Contract for managing a lowest/highest unique bid auction.
 */
contract UniqueAuction is BaseAuction {
    uint public decimalCount;
    uint public totalBidsAllowed;

    /**
     * @dev Constructor to initialize the lowest unique bid auction.
     * @param _owner The address of the auction owner.
     * @param _product The product details for the auction.
     * @param _auction The unique auction details.
     */
    constructor(
        address _owner,
        ProductStruct memory _product,
        UniqueAuctionInfo memory _auction,
        AuctionHouseDetails memory _auctionHouseDetails,
        AuctionTypeStruct memory _auctionType
    ) BaseAuction(_owner) {
        _setAuctionHouseDetails(address(this), _auctionHouseDetails);
        _setProductAndAuctionType(_product, _auctionType);

        auctionTitle = _auction.title;
        registrationRequired = _auction.registration;
        participantCount = _auction.participantCount;
        playsConsumedPerBid = _auction.playsConsumedPerBid;
        registrationFees = _auction.registrationFees;
        termsAndConditions = _auction.termsAndConditions;
        auctionInformation = _auction.auctionInformation;
        decimalCount = _auction.decimalCount;
        totalBidsAllowed = _auction.totalBids;
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
        EditUniqueAuction memory auction,
        AuctionTypeStruct memory _auctionType
    ) external isNotDeleted isUpcoming onlyOwner {
        _editAuctionCommonFields(
            auction.title,
            auction.participantCount,
            auction.termsAndConditions,
            auction.auctionInformation,
            _auctionType
        );
        decimalCount = auction.decimalCount;
        totalBidsAllowed = auction.totalBids;

        emit AuctionEdited();
    }
}
