// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./Custodian.sol";

contract CustodianFactory {
    address public immutable tokenAddress;
    address public immutable quarterlyBurnAddr;
    address public immutable platformGasFeesAddr;

    mapping(address => bool) private hasDeployedCustodian;

    event CustodianDeployed(
        address indexed custodian,
        address auctionHouseAdmin
    );

    constructor(
        address _tokenAddress,
        address _quarterlyBurnAddr,
        address _platformGasFeesAddr
    ) {
        tokenAddress = _tokenAddress;
        quarterlyBurnAddr = _quarterlyBurnAddr;
        platformGasFeesAddr = _platformGasFeesAddr;
    }

    function deployCustodian() external {
        require(
            !hasDeployedCustodian[msg.sender],
            "Custodian already deployed by this address"
        );

        Custodian newCustodian = new Custodian(
            msg.sender,
            quarterlyBurnAddr,
            tokenAddress,
            platformGasFeesAddr
        );

        hasDeployedCustodian[msg.sender] = true;

        emit CustodianDeployed(address(newCustodian), msg.sender);
    }

    function hasDeployed(address _adminAddr) external view returns (bool) {
        return hasDeployedCustodian[_adminAddr];
    }
}
