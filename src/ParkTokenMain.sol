// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ParkTokenMain is ERC20 {

    address owner;
    constructor(address _owner) ERC20("ParkToken", "PARK") {
        _mint(_owner, 1_000_000_000 ether);
    }

    function mint() external payable {
        require(msg.value > 0);
        _mint(msg.sender, msg.value);
    }

}