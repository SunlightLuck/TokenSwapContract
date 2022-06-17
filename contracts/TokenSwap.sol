pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenA.sol";
import "./TokenB.sol";

contract TokenSwap {
    struct Order {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        bool isSet;
    }

    IERC20 public token;
    uint256 public _totalOrder;
    // mapping(uint256 => Order) private _orderList;
    Order[] _orderList;

    event SellOrderCreated(
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address owner
    );
    event SellOrderCancelled(uint256 orderId, bool status);
    event BuyOrderFilled(
        uint256 orderId,
        uint256 amount,
        uint256 paid,
        address seller,
        address buyer
    );

    TokenA public _tokenA;
    TokenB public _tokenB;

    constructor(address tokenA, address tokenB) {
        _tokenA = TokenA(tokenA);
        _tokenB = TokenB(tokenB);
    }

    function totalOrder() external view returns (uint256) {
        return _totalOrder;
    }

    function ownerOf(uint256 orderId) external view returns (address) {
        return _orderList[orderId].owner;
    }

    function CreateSellOrder(
        uint256 tokenId,
        uint256 volume,
        uint256 price,
        address owner
    ) public {
        Order memory newOrder = Order(owner, tokenId, volume, price, true);
        _orderList.push(newOrder);
        // _orderList[_totalOrder] = newOrder;
        _totalOrder += 1;
    }

    function CancelSellOrder(uint256 orderId, address owner) public {
        require(owner == _orderList[orderId].owner, "It's not yours");
        _orderList[orderId] = _orderList[_totalOrder - 1];
        _orderList.pop();
        _totalOrder -= 1;
        emit SellOrderCancelled(orderId, false);
    }

    function BuyOrder(
        uint256 projectId,
        uint256 bundleId,
        uint256 volume,
        address owner
    ) public {}
}
