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
        require(msg.sender == owner, "Only owner is available");
        Order memory newOrder = Order(owner, tokenId, volume, price, true);
        _orderList.push(newOrder);
        // _orderList[_totalOrder] = newOrder;
        _tokenA.transferFrom(owner, address(this), volume);
        _totalOrder += 1;
    }

    function CancelSellOrder(uint256 orderId, address owner) public {
        require(owner == _orderList[orderId].owner, "It's not yours");
        require(owner == msg.sender, "Only owner is available");

        _tokenA.transferFrom(address(this), owner, _orderList[orderId].amount);

        _totalOrder -= 1;
        emit SellOrderCancelled(orderId, false);
    }

    function BuyOrder(
        uint256 projectId,
        uint256 bundleId,
        uint256 volume,
        address owner
    ) public {
        require(msg.sender == owner, "Only owner is available");
        require(_orderList[bundleId].amount >= volume, "Not enought toke");
        require(bundleId <= _totalOrder, "Invalid order");

        Order memory order = _orderList[bundleId];

        uint256 exchangeAmount = volume * (order.price + 0.5 ether);
        exchangeAmount = exchangeAmount + (exchangeAmount * 2) / 100;

        require(_tokenB.balanceOf(owner) >= exchangeAmount, "Not enough token");

        _tokenB.transferFrom(owner, address(this), exchangeAmount);

        _tokenA.transferFrom(address(this), owner, volume);
        _tokenB.transferFrom(address(this), order.owner, exchangeAmount);

        if (order.amount == volume) {
            _orderList[bundleId] = _orderList[_totalOrder - 1];
            _orderList.pop();
            _totalOrder -= 1;
        } else {
            _orderList[bundleId].amount -= volume;
        }

        emit BuyOrderFilled(
            bundleId,
            _orderList[bundleId].amount,
            _orderList[bundleId].price,
            _orderList[bundleId].owner,
            owner
        );
    }
}
