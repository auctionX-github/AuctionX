// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./structs/AuctionStruct.sol";
import "./structs/ProductStruct.sol";
import "./structs/AuctionTypeStruct.sol";
import "./structs/BidLogStruct.sol";
import "./structs/AuctionHouseStruct.sol";

/**
 * @title BaseAuction
 * @dev Abstract contract providing basic functionality for managing auctions.
 */
abstract contract BaseAuction is Ownable2Step {
    string public ipfsUrl;

    // Auction House Variables
    address public auctionHouseContractAddress;
    string public auctionHouseID;
    string public auctionHouseName;
    string public auctionHouseUrl;

    // ProductStruct State Variables
    string public productTitle;
    string public productDescription;
    string public productPrice;

    // AuctionTypeStruct State Variables
    string public auctionTypeTitle;

    // Auction State Variables
    string public auctionTitle;
    bool public registrationRequired;
    uint public participantCount;
    uint public playsConsumedPerBid;
    uint public registrationFees;
    string public termsAndConditions;
    string public auctionInformation;
    AuctionState public state;
    string[] private _stateStrings = [
        "Upcoming",
        "Live",
        "Completed",
        "Canceled"
    ];

    bool private _deleted;

    modifier isUpcoming() {
        require(
            state == AuctionState.Upcoming,
            "Auction can only be edited if it is in the upcoming state!"
        );
        _;
    }

    modifier isLiveOrCompleted() {
        require(
            state == AuctionState.Live || state == AuctionState.Completed,
            "Auction bids can only be added if it is in the Live/Completed state!"
        );
        _;
    }

    modifier isNotDeleted() {
        require(!_deleted, "Auction is deleted!");
        _;
    }

    modifier validStateTransition(AuctionState _newState) {
        require(
            (state == AuctionState.Upcoming &&
                (_newState == AuctionState.Live ||
                    _newState == AuctionState.Cancelled)) ||
                (state == AuctionState.Live &&
                    _newState == AuctionState.Completed),
            "Invalid state transition!"
        );
        _;
    }

    event AuctionStateUpdated();
    event AuctionDeleted();
    event AuctionHouseSet();
    event ProductAndAuctionTypeSet();
    event AuctionInfoEdited();
    event AuctionTypeSet();

    constructor(address _owner) Ownable(_owner) {}

    function addIpfsHash(
        string memory _ipfsUrl
    ) external isNotDeleted isLiveOrCompleted onlyOwner {
        ipfsUrl = _ipfsUrl;
    }

    /**
     * @dev Changes the state of the auction.
     * @param _newState The new state to transition to.
     */
    function changeState(
        AuctionState _newState
    ) external isNotDeleted onlyOwner validStateTransition(_newState) {
        require(state != _newState, "New state has to be different.");
        state = _newState;

        emit AuctionStateUpdated();
    }

    /**
     * @dev Deletes the auction.
     */
    function deleteAuction() external isNotDeleted isUpcoming onlyOwner {
        _deleted = true;

        emit AuctionDeleted();
    }

    function _setAuctionHouseDetails(
        address _auctionHouseContractAddress,
        AuctionHouseDetails memory _auctionHouseDetails
    ) internal {
        auctionHouseContractAddress = _auctionHouseContractAddress;
        auctionHouseID = _auctionHouseDetails.id;
        auctionHouseName = _auctionHouseDetails.name;
        auctionHouseUrl = _auctionHouseDetails.url;

        emit AuctionHouseSet();
    }

    /**
     * @dev Creates a new auction with given product and auction type.
     * @param _product The product details for the auction.
     * @param _auctionType The type of the auction.
     */
    function _setProductAndAuctionType(
        ProductStruct memory _product,
        AuctionTypeStruct memory _auctionType
    ) internal {
        productTitle = _product.title;
        productDescription = _product.description;
        productPrice = _product.price;

        _setAuctionType(_auctionType);

        emit ProductAndAuctionTypeSet();
    }

    /**
     * @dev Common function to edit auction details.
     * @param _title The new title of the auction.
     * @param _participantCount The new participant count of the auction.
     * @param _termsAndConditions The new terms and conditions of the auction.
     * @param _auctionInformation The new auction information.
     * @param _auctionType The new type of the auction.
     */
    function _editAuctionCommonFields(
        string memory _title,
        uint _participantCount,
        string memory _termsAndConditions,
        string memory _auctionInformation,
        AuctionTypeStruct memory _auctionType
    ) internal {
        auctionTitle = _title;
        participantCount = _participantCount;
        termsAndConditions = _termsAndConditions;
        auctionInformation = _auctionInformation;
        _setAuctionType(_auctionType);

        emit AuctionInfoEdited();
    }

    /**
     * @dev Internal function to set the auction type.
     * @param _auctionType The type of the auction.
     */
    function _setAuctionType(AuctionTypeStruct memory _auctionType) internal {
        auctionTypeTitle = _auctionType.title;

        emit AuctionTypeSet();
    }

    /**
     * @dev Retrieves the current state of the auction.
     * @return A string indicating the current state of the auction.
     */
    function getState() external view returns (string memory) {
        return _stateStrings[uint(state)];
    }

    /**
     * @dev Checks if the auction is deleted.
     * @return A boolean indicating whether the auction is deleted.
     */
    function isDeleted() external view returns (bool) {
        return _deleted;
    }
}
