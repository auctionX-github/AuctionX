// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./GovernanceRewards.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PlatformGasFee is ReentrancyGuard, Ownable2Step {
    using SafeERC20 for IERC20;
    IERC20 public immutable tokenAddress;
    GovernanceRewards public immutable governanceRewardsAddr;

    uint256 public superAdminShare = 75;
    uint256 public governanceShare = 25;

    constructor(
        address _tokenAddress,
        address _governanceRewardsAddr
    ) Ownable(msg.sender) {
        tokenAddress = IERC20(_tokenAddress);
        governanceRewardsAddr = GovernanceRewards(_governanceRewardsAddr);
    }

    event TokenRetrieved();
    event SharesUpdated(
        uint256 indexed _superAdminShare,
        uint256 indexed _governanceShare
    );

    function retrieveAuX(uint256 _amount) external nonReentrant {
        IERC20 _tokenAddress = tokenAddress;
        _tokenAddress.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _superAdminShare = (_amount * 75) / 100;
        uint256 _governanceShare = (_amount * 25) / 100;

        _tokenAddress.safeTransfer(owner(), _superAdminShare);
        _tokenAddress.safeTransfer(
            address(governanceRewardsAddr),
            _governanceShare
        );

        emit TokenRetrieved();
    }

    function updateShares(
        uint256 _superAdminShare,
        uint256 _governanceShare
    ) external onlyOwner {
        require(_superAdminShare + _governanceShare == 100, "Sum not 100!");

        uint256 _memSuperAdminShare = superAdminShare;
        uint256 _memGovernanceShare = governanceShare;

        if (
            _memSuperAdminShare != _superAdminShare &&
            _memGovernanceShare != _governanceShare
        ) {
            _memSuperAdminShare = _superAdminShare;
            _memGovernanceShare = _governanceShare;

            emit SharesUpdated(_superAdminShare, _governanceShare);
        }
    }
}
