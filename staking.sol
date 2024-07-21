// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Staking is ReentrancyGuard, Ownable2Step {
    using SafeERC20 for IERC20;
    IERC20 public immutable stakingTokenAddr;
    address private immutable _cachedAddress;
    uint256 private _totalStaked;

    struct Staker {
        uint256 amount;
        bool unstakeApproval;
    }
    mapping(address stakerAddr => Staker stakerInfo) private _stakes;
    address[] private _stakerAddresses;

    event Stake(address indexed _staker);
    event ApproveUnstake(address indexed _staker);
    event Unstake(address indexed _staker);

    constructor(address _stakingToken) Ownable(msg.sender) {
        stakingTokenAddr = IERC20(_stakingToken);
        _cachedAddress = address(this);
    }

    function stake(uint256 _amount) external nonReentrant {
        require(_amount != 0, "Cannot stake 0 tokens.");

        Staker storage userStake = _stakes[msg.sender];
        IERC20 _stakingTokenAddr = stakingTokenAddr;
        address cachedAddress = _cachedAddress;

        require(
            _stakingTokenAddr.balanceOf(msg.sender) > _amount - 1,
            "Insufficient token balance."
        );
        require(
            _stakingTokenAddr.allowance(msg.sender, cachedAddress) >
                _amount - 1,
            "Approve tokens for this spender."
        );

        if (userStake.amount >= 1) {
            userStake.amount += _amount;
        } else {
            userStake.amount = _amount;
            userStake.unstakeApproval = false;
            _stakerAddresses.push(msg.sender);

            emit Stake(msg.sender);
        }

        _totalStaked = _totalStaked + _amount;
        _stakingTokenAddr.safeTransferFrom(msg.sender, cachedAddress, _amount);
    }

    function approveUnstake(address _staker) external onlyOwner {
        Staker storage userStake = _stakes[_staker];

        require(userStake.amount != 0, "No stake found for the address.");
        require(!userStake.unstakeApproval, "Already approved.");

        userStake.unstakeApproval = true;
        emit ApproveUnstake(_staker);
    }

    function unstake() external nonReentrant {
        Staker storage userStake = _stakes[msg.sender];

        uint256 _amount = userStake.amount;
        require(_amount != 0, "No stake found for the address.");
        require(userStake.unstakeApproval, "Unstake not approved by owner.");

        _totalStaked = _totalStaked - _amount;

        stakingTokenAddr.safeTransfer(msg.sender, _amount);

        address[] storage stakerAddresses = _stakerAddresses;
        uint256 stakerAddressesLen = stakerAddresses.length;

        for (uint256 i = 0; i < stakerAddressesLen; ++i) {
            address _stakerAddr = stakerAddresses[i];
            if (_stakerAddr == msg.sender) {
                _stakerAddr = stakerAddresses[stakerAddressesLen - 1];
                stakerAddresses.pop();
                break;
            }
        }

        userStake.amount = 0;

        emit Unstake(msg.sender);
    }

    function getTotalStaked() external view returns (uint256) {
        return _totalStaked;
    }

    function getTotalStakedByAddr(
        address _addr
    ) external view returns (uint256) {
        return _stakes[_addr].amount;
    }

    function getAllStakers() external view returns (address[] memory) {
        return _stakerAddresses;
    }
}
