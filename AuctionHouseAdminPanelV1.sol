// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./UniqueAuction.sol";
import "./TheLastPlay.sol";

error UnsupportedAuctionType();

contract AuctionHouseAdminPanelV1 is Ownable2Step {
    string private _auctionHouseId;
    string private _auctionHouseName;
    string private _auctionHouseUrl;

    /**
     * @dev Constructor that sets the contract deployer as the owner.
     */
    constructor(
        address _ownerAddr,
        AuctionHouseDetails memory _auctionHouseDetails
    ) Ownable(_ownerAddr) {
        _auctionHouseId = _auctionHouseDetails.id;
        _auctionHouseName = _auctionHouseDetails.name;
        _auctionHouseUrl = _auctionHouseDetails.url;
    }

    /**
     * @dev Emitted when a new auction is created.
     * @param auctionId The ID of the created auction.
     * @param auctionAddress The address of the created auction contract.
     */
    event AuctionCreated(string auctionId, address auctionAddress);

    /**
     * @notice Creates a new auction instance.
     * @param auctionType The type of auction to create ('Lowest Unique Bid' or 'Highest Unique Bid' or 'The Last Play').
     * @param auctionId The ID of the auction.
     * @param product The product associated with the auction.
     * @param auction The details of the auction.
     */
    function createAuction(
        string memory auctionType,
        string memory auctionId,
        ProductStruct memory product,
        bytes memory auction
    ) external onlyOwner {
        address auctionInstance;

        AuctionHouseDetails memory auctionHouseDetails = AuctionHouseDetails(
            _auctionHouseId,
            _auctionHouseName,
            _auctionHouseUrl
        );

        if (
            keccak256(abi.encodePacked(auctionType)) ==
            keccak256("Lowest Unique Bid")
        ) {
            auctionInstance = address(
                new UniqueAuction(
                    owner(),
                    product,
                    abi.decode(auction, (UniqueAuctionInfo)),
                    auctionHouseDetails,
                    AuctionTypeStruct({title: auctionType})
                )
            );
        } else if (
            keccak256(abi.encodePacked(auctionType)) ==
            keccak256("Highest Unique Bid")
        ) {
            auctionInstance = address(
                new UniqueAuction(
                    owner(),
                    product,
                    abi.decode(auction, (UniqueAuctionInfo)),
                    auctionHouseDetails,
                    AuctionTypeStruct({title: auctionType})
                )
            );
        } else if (
            keccak256(abi.encodePacked(auctionType)) ==
            keccak256("The Last Play")
        ) {
            auctionInstance = address(
                new TheLastPlay(
                    owner(),
                    product,
                    abi.decode(auction, (TheLastPlayAuctionInfo)),
                    auctionHouseDetails
                )
            );
        } else {
            revert UnsupportedAuctionType();
        }

        emit AuctionCreated(auctionId, auctionInstance);
    }

    function getAuctionHouseId() external view returns (string memory) {
        return _auctionHouseId;
    }

    function getAuctionHouseName() external view returns (string memory) {
        return _auctionHouseName;
    }

    function getAuctionHouseUrl() external view returns (string memory) {
        return _auctionHouseUrl;
    }
}
