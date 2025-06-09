// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Auction {
    struct Bider {
        uint256 value;
        address bider;
    }

    event NewOffer(address indexed bider, uint256 amount);
    event AuctionEnded();

    address private owner;
    uint256 private startTime;
    uint256 private stopTime;

    Bider public winner;
    Bider[] private biders;
    mapping(address => Bider[]) private offers;
    mapping(address => uint256) private balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "No autorizado");
        _;
    }

    modifier isActive() {
        require(block.timestamp < stopTime, "La subasta ha finalizado");
        _;
    }

    constructor(uint256 _duration) {
        owner = msg.sender;
        startTime = block.timestamp;
        stopTime = startTime + _duration;
    }

    function bid() external payable isActive {
        require(msg.value > 0, "Oferta invalida");
        require(msg.value >= (winner.value * 105) / 100, "La oferta debe superar en al menos 5%");

        if (stopTime - block.timestamp <= 10 minutes) {
            stopTime += 10 minutes;
        }

        biders.push(Bider(msg.value, msg.sender));
        offers[msg.sender].push(Bider(msg.value, msg.sender));
        balances[msg.sender] += msg.value;

        winner.value = msg.value;
        winner.bider = msg.sender;

        emit NewOffer(msg.sender, msg.value);
    }

    function showWinner() external view returns (Bider memory) {
        require(block.timestamp >= stopTime, "Subasta activa");
        return winner;
    }

    function showOffers() external view returns (Bider[] memory) {
        return biders;
    }

    function refund() external onlyOwner {
        require(block.timestamp >= stopTime, "Subasta no finalizada");

        for (uint256 i = 0; i < biders.length; i++) {
            address bidderAddr = biders[i].bider;
            if (bidderAddr != winner.bider && balances[bidderAddr] > 0) {
                uint256 refundAmount = (balances[bidderAddr] * 98) / 100;
                balances[bidderAddr] = 0;
                payable(bidderAddr).transfer(refundAmount);
            }
        }

        emit AuctionEnded();
    }

    function partialRefund() external {
        Bider[] storage userOffers = offers[msg.sender];
        require(userOffers.length >= 2, "Debes tener mas de una oferta");

        uint256 latest = userOffers[userOffers.length - 1].value;
        uint256 totalPrev = 0;

        for (uint256 i = 0; i < userOffers.length - 1; i++) {
            totalPrev += userOffers[i].value;
        }

        require(totalPrev > 0, "Nada que reembolsar");

        balances[msg.sender] -= totalPrev;
        delete offers[msg.sender];
        offers[msg.sender].push(Bider(latest, msg.sender));

        payable(msg.sender).transfer(totalPrev);
    }

    receive() external payable {
        revert("Usar la funcion bid()");
    }
}
