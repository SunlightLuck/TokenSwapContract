pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "TA") {}

    function mint(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(from, to, amount);
        return true;
    }
}
