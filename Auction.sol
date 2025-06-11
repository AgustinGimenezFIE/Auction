// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Auction
 * @notice This contract manages a timed auction with automatic refund and bid tracking
 */
contract Auction {
    struct Bidder {
        uint256 value;
        address bidder;
    }

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionClosed();

    address private owner;
    uint256 private startTime;
    uint256 private stopTime;

    Bidder public winner;
    Bidder[] private allBids;
    mapping(address => Bidder[]) private bidHistory;
    mapping(address => uint256) private balances;
    mapping(address => bool) private refunded;

    modifier onlyOwner() {
        require(msg.sender == owner, "NotOwner");
        _;
    }

    modifier isActive() {
        require(block.timestamp < stopTime, "Ended");
        _;
    }

    /**
     * @notice Constructor sets the auction duration and owner
     * @param _duration Auction duration in seconds
     */
    constructor(uint256 _duration) {
        owner = msg.sender;
        startTime = block.timestamp;
        stopTime = startTime + _duration;
    }

    /**
     * @notice Place a new bid with at least 5% increase over current
     */
    function bid() external payable isActive {
        require(msg.value > 0, "Zero");
        require(msg.value >= (winner.value * 105) / 100, "TooLow");

        if (stopTime - block.timestamp <= 600) {
            stopTime += 600;
        }

        Bidder memory newBid = Bidder(msg.value, msg.sender);
        allBids.push(newBid);
        bidHistory[msg.sender].push(newBid);
        balances[msg.sender] += msg.value;

        winner = newBid;

        emit NewBid(msg.sender, msg.value);
    }

    /**
     * @notice Return winning bid after auction ends
     * @return The winning Bidder struct
     */
    function showWinner() external view returns (Bidder memory) {
        require(block.timestamp >= stopTime, "Ongoing");
        return winner;
    }

    /**
     * @notice View all bids placed
     * @return Array of all Bidder structs
     */
    function showOffers() external view returns (Bidder[] memory) {
        return allBids;
    }

    /**
     * @notice Refund non-winning bidders with 2% fee
     * @dev Can only be called once per address, by owner, after auction ends
     */
    function refund() external onlyOwner {
        require(block.timestamp >= stopTime, "NotDone");
        uint256 len = allBids.length;

        for (uint256 i = 0; i < len; i++) {
            address bidderAddr = allBids[i].bidder;
            uint256 bal = balances[bidderAddr];

            if (bidderAddr != winner.bidder && bal > 0 && !refunded[bidderAddr]) {
                uint256 refundAmount = (bal * 98) / 100;
                balances[bidderAddr] = 0;
                refunded[bidderAddr] = true;
                payable(bidderAddr).transfer(refundAmount);
            }
        }

        emit AuctionClosed();
    }

    /**
     * @notice Withdraw all previous bids except the last one
     * @dev Keeps only the latest bid active for current user
     */
    function withdrawExcess() external {
        Bidder[] storage userBids = bidHistory[msg.sender];
        uint256 len = userBids.length;

        require(len >= 2, "Need2");

        uint256 latest = userBids[len - 1].value;
        uint256 totalPrev = 0;

        for (uint256 i = 0; i < len - 1; i++) {
            totalPrev += userBids[i].value;
        }

        require(totalPrev > 0, "Zero");

        balances[msg.sender] -= totalPrev;
        delete bidHistory[msg.sender];
        bidHistory[msg.sender].push(Bidder(latest, msg.sender));

        payable(msg.sender).transfer(totalPrev);
    }

    /**
     * @notice Emergency function to withdraw stuck ETH
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        revert("UseBid");
    }
}
