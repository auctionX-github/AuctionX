// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./AuctionHouseAdminPanelV1.sol";

contract LaunchAuctionHouse {
    event AuctionHouseCreated(
        string indexed _auctionHouseId,
        address _auctionHouseAddress
    );

    mapping(string auctionHouseId => bool isExist) private _auctionHouseIds;

    modifier notEmptyString(string memory _str) {
        require(bytes(_str).length > 0, "String cannot be empty!");
        _;
    }

    modifier uniqueAuctionHouseId(string memory _auctionHouseId) {
        require(
            !_auctionHouseIds[_auctionHouseId],
            "Auction house ID already exists!"
        );
        _;
    }

    function launchHouse(
        AuctionHouseDetails memory _auctionHouseDetails
    )
        external
        notEmptyString(_auctionHouseDetails.id)
        notEmptyString(_auctionHouseDetails.name)
        notEmptyString(_auctionHouseDetails.url)
        uniqueAuctionHouseId(_auctionHouseDetails.id)
    {
        AuctionHouseAdminPanelV1 auctionHouseIns = new AuctionHouseAdminPanelV1(
            msg.sender,
            _auctionHouseDetails
        );

        _auctionHouseIds[_auctionHouseDetails.id] = true;

        emit AuctionHouseCreated(
            _auctionHouseDetails.id,
            address(auctionHouseIns)
        );
    }
}
