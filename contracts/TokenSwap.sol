pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSwap {
    struct Order {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        bool isSet;
    }

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

    IERC20 public _tokenA;
    IERC20 public _tokenB;

    constructor(address tokenA, address tokenB) {
        _tokenA = IERC20(tokenA);
        _tokenB = IERC20(tokenB);
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

        uint256 tokenFee = (volume * 2) / 100;
        uint256 usdtFee = volume * 0.2 ether;
        IERC20 usdt = IERC20(
            address(0x5FbDB2315678afecb367f032d93F642f64180aa3)
        );

        require(
            _tokenB.balanceOf(owner) >= volume + tokenFee,
            "Not enough token"
        );
        require(usdt.balanceOf(owner) >= usdtFee, "Not enough USDT");

        _tokenB.transferFrom(owner, order.owner, volume);
        _tokenB.transferFrom(owner, address(this), tokenFee);

        _tokenA.transferFrom(address(this), owner, volume);
        usdt.transferFrom(owner, address(this), usdtFee);

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
