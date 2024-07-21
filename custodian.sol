// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./PlatformGasFee.sol";
import "./QuarterBurn.sol";

contract Custodian is Ownable2Step {
    using SafeERC20 for IERC20;
    IERC20 public immutable tokenAddress;

    // Convert to private and create getter function if buisness logic demands so.
    QuarterBurn public immutable quarterlyBurnAddr;
    PlatformGasFee public immutable platformGasFeesAddr;

    constructor(
        address ownerAddr,
        address _quarterlyBurnAddr,
        address _tokenAddress,
        address _platformGasFeesAddr
    ) Ownable(ownerAddr) {
        quarterlyBurnAddr = QuarterBurn(_quarterlyBurnAddr);
        tokenAddress = IERC20(_tokenAddress);
        platformGasFeesAddr = PlatformGasFee(_platformGasFeesAddr);
    }

    event TokenRetrieved();

    function retrieveAuX() external onlyOwner {
        IERC20 _tokenAddress = tokenAddress;
        PlatformGasFee _platformGasFeesAddr = platformGasFeesAddr;

        uint256 totalAuXDeposited = _tokenAddress.balanceOf(address(this));
        require(totalAuXDeposited != 0, "Insufficient balance.");

        uint256 auctionHouseAdminShare = (totalAuXDeposited * 95) / 100;
        uint256 quarterlyBurnShare = (totalAuXDeposited * 1) / 100;
        uint256 platformGasFeesShare = (totalAuXDeposited * 4) / 100;

        _tokenAddress.safeTransfer(owner(), auctionHouseAdminShare);

        _tokenAddress.safeTransfer(
            address(quarterlyBurnAddr),
            quarterlyBurnShare
        );

        _tokenAddress.approve(
            address(_platformGasFeesAddr),
            platformGasFeesShare
        );

        _platformGasFeesAddr.retrieveAuX(platformGasFeesShare);

        emit TokenRetrieved();
    }
}
