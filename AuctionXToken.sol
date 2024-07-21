// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AuctionXToken
 * @dev ERC20 token with burnable and ownable features.
 */
contract AuctionXToken is ERC20, ERC20Burnable, Ownable {
    /**
     * @dev Constructor that gives `initialOwner` all of the existing tokens.
     * @param _initialOwner The address of the initial owner of the tokens.
     * @param _tokenName The name of the token.
     * @param _tokenSymbol The symbol of the token.
     * @param _premintAmt The amount of tokens to mint initially.
     */
    constructor(
        address _initialOwner,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _premintAmt
    ) ERC20(_tokenName, _tokenSymbol) Ownable(_initialOwner) {
        _mint(_initialOwner, _premintAmt * 1e18);
    }
}
