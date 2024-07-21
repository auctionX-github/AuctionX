// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract QuarterBurn is Ownable2Step, ReentrancyGuard {
    uint256 private constant _UNIX_YEAR = 1970;
    uint256 private immutable _SECONDS_PER_DAY = 86400;

    uint256 public nextBurnTimestamp;

    ERC20Burnable public immutable tokenAddr;

    address private _upkeepAddress;

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tokenAddr = ERC20Burnable(_tokenAddress);
        nextBurnTimestamp = getNextQuarterTimestamp();
    }

    event TokensBurned(uint256 indexed _amountBurned);
    event UpkeepAddressSet(address indexed _upkeepAddress);

    modifier onlyOwnerOrUpkeep() {
        require(
            msg.sender == owner() || msg.sender == _upkeepAddress,
            "Caller is not the owner or forwarder."
        );
        _;
    }

    modifier upkeepNeeded() {
        require(block.timestamp >= nextBurnTimestamp, "Not time yet.");
        _;
    }

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

    function burnTokensQuaterly()
        external
        upkeepNeeded
        nonReentrant
        onlyOwnerOrUpkeep
    {
        ERC20Burnable _tokenAddr = tokenAddr;

        uint256 tokenBal = _tokenAddr.balanceOf(address(this));

        require(tokenBal != 0, "Token balance is 0.");

        _tokenAddr.burn(tokenBal);
        emit TokensBurned(tokenBal);
    }

    function setUpkeepAddress(address _upkeepAddr) external onlyOwner {
        require(_upkeepAddress != _upkeepAddr, "Invalid upkeep address");

        _upkeepAddress = _upkeepAddr;
        emit UpkeepAddressSet(_upkeepAddr);
    }
}
