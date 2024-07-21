// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct BidLogStruct {
    address player_address;
    uint256 bid_price;
    uint256 bid_number;
    uint256 remaining_seconds;
    uint256 created_at;
    uint256 player_bot_id;
    bool is_unique;
    bool is_lowest;
    bool is_highest;
}
