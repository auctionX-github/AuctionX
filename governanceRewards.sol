// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Staking.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GovernanceRewards is Ownable2Step, ReentrancyGuard {
    uint256 private constant _UNIX_YEAR = 1970;
    uint256 private immutable _SECONDS_PER_DAY = 86400;

    uint256 public nextRewardTimestamp;

    address private immutable _cachedAddress;
    address private _upkeepAddress;

    Staking public immutable stakingAddr;

    using SafeERC20 for ERC20;
    ERC20 public immutable tokenAddress;

    constructor(
        address _stakingAddr,
        address _tokenAddress
    ) Ownable(msg.sender) {
        stakingAddr = Staking(_stakingAddr);
        nextRewardTimestamp = getNextQuarterTimestamp();
        tokenAddress = ERC20(_tokenAddress);
        _cachedAddress = address(this);
    }

    modifier onlyOwnerOrUpkeep() {
        require(
            msg.sender == owner() || msg.sender == _upkeepAddress,
            "Caller is not the owner or forwarder."
        );
        _;
    }

    modifier upkeepNeeded() {
        require(block.timestamp >= nextRewardTimestamp, "Not time yet.");
        _;
    }

    event RewardsTransferred(uint256 indexed _totalRewardAmount);
    event UpkeepAddressSet(address indexed _upkeepAddress);

    function isLeapYear(uint256 _year) internal pure returns (bool) {
        return _year % 4 == 0;
    }

    function getCurrentYear() internal view returns (uint256 _currentYear) {
        _currentYear = (block.timestamp / 365 days) + _UNIX_YEAR;
        return _currentYear;
    }

    function getNextQuarterTimestamp() internal view returns (uint256) {
        uint256 _leapYearsCount = 0;
        uint256 _currentYear = getCurrentYear();
        uint256 _unixYear = _UNIX_YEAR;
        uint256 _secondsPerDay = _SECONDS_PER_DAY;

        for (uint256 y = _unixYear; y < _currentYear; ++y) {
            if (isLeapYear(y)) {
                _leapYearsCount++;
            }
        }

        uint256 _startOfYear = ((getCurrentYear() - _unixYear) *
            365 *
            _secondsPerDay) + (_leapYearsCount * _secondsPerDay);

        uint256 _timeIntoYear = block.timestamp - _startOfYear;

        uint256 _quarterDuration;
        if (isLeapYear(getCurrentYear())) {
            if (_timeIntoYear < 91 days) {
                _quarterDuration = 91 days;
            } else if (_timeIntoYear < 182 days) {
                _quarterDuration = 182 days;
            } else if (_timeIntoYear < 274 days) {
                _quarterDuration = 274 days;
            } else {
                _quarterDuration = 366 days;
            }
        } else {
            if (_timeIntoYear < 90 days) {
                _quarterDuration = 90 days;
            } else if (_timeIntoYear < 181 days) {
                _quarterDuration = 181 days;
            } else if (_timeIntoYear < 273 days) {
                _quarterDuration = 273 days;
            } else {
                _quarterDuration = 365 days;
            }
        }

        return _startOfYear + _quarterDuration;
    }

    function _rewardShare(
        address _addr
    ) internal view returns (uint256 _reward) {
        Staking _stakingAddr = stakingAddr;

        uint256 _amtStakedByAddr = _stakingAddr.getTotalStakedByAddr(_addr);
        uint256 _amtTotalStaked = _stakingAddr.getTotalStaked();

        require(_amtStakedByAddr != 0, "Address has no staked tokens.");

        _reward =
            (tokenAddress.balanceOf(_cachedAddress) * _amtStakedByAddr) /
            _amtTotalStaked;
    }

    function distributeRewardsQuaterly()
        external
        upkeepNeeded
        nonReentrant
        onlyOwnerOrUpkeep
    {
        ERC20 _tokenAddress = tokenAddress;
        uint256 _tokenBalance = _tokenAddress.balanceOf(_cachedAddress);

        require(_tokenBalance != 0, "Token balance is 0.");

        address[] memory _stakers = stakingAddr.getAllStakers();
        uint256 _stakersLen = _stakers.length;

        uint256 batchSize = 50;
        uint256 startIdx = 0;

        while (startIdx < _stakersLen) {
            uint256 endIdx = startIdx + batchSize;
            if (endIdx > _stakersLen) {
                endIdx = _stakersLen;
            }

            uint256[] memory _rewards = new uint256[](endIdx - startIdx);

            for (uint256 i = startIdx; i < endIdx; i++) {
                _rewards[i - startIdx] = _rewardShare(_stakers[i]);
            }

            for (uint256 i = startIdx; i < endIdx; i++) {
                _tokenAddress.safeTransfer(_stakers[i], _rewards[i - startIdx]);
            }

            startIdx = endIdx;
        }

        emit RewardsTransferred(_tokenBalance);
    }

    function setUpkeepAddress(address _upkeepAddr) external onlyOwner {
        require(_upkeepAddress != _upkeepAddr, "Invalid upkeep address");

        _upkeepAddress = _upkeepAddr;
        emit UpkeepAddressSet(_upkeepAddr);
    }
}
