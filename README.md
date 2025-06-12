# 🧾 Auction Smart Contract

This Solidity smart contract implements a timed auction system with enforced bid increments, refund logic, event logging, and security best practices
https://sepolia.etherscan.io/address/0x2766f7459583c4ed261aab985ae8fe2594841a42

## ✅ Features

### 🛠 Constructor

- `constructor(uint256 _duration)`: Initializes the auction with a given duration (in seconds) and sets the contract deployer as the owner.

### 💸 `bid()`

- Allows any user to place a bid.
- Requirements:
  - Must exceed the current highest bid by at least 5%.
  - Must be sent while the auction is active.
- If a bid is placed within the final 10 minutes, the auction is extended by 10 more minutes.
- Tracks each bid and bidder.
- Emits `NewBid(address bidder, uint256 amount)`.

### 🏆 `showWinner()`

- Returns the winning bid and bidder information.
- Only accessible after the auction has ended.

### 📜 `showOffers()`

- Returns the full list of all bids placed.

### 🔁 `refund()`

- Can only be executed by the owner after the auction ends.
- Refunds 98% of the total ETH to all non-winning bidders.
- Refund is only sent once per bidder.
- Emits `AuctionClosed()`.

### 🧮 `withdrawExcess()`

- Allows a user who placed multiple bids to reclaim all ETH sent except for their final bid.
- Only works if the user has placed at least two bids.

### 🚨 `emergencyWithdraw()`

- Allows the owner to withdraw the contract balance in case of an emergency.

### ⛔ `receive()`

- Reverts any plain ETH transfers. Forces users to interact via the `bid()` function.

---

## 🧪 Testing Guide

1. **Deploy**
   - Deploy the contract passing auction duration (e.g., `3600` for 1 hour).
2. **Bidding**
   - Connect multiple test accounts.
   - Call `bid()` with valid amounts (must be at least 5% higher than the last).
3. **View Offers**
   - Call `showOffers()` to retrieve bid history.
4. **Check Winner**
   - After the auction ends (based on `stopTime`), call `showWinner()`.
5. **Excess Withdrawal**
   - If a user placed multiple bids, call `withdrawExcess()` to get previous bids back.
6. **Refunds**
   - The owner should call `refund()` after auction ends to refund all non-winners (with 2% fee).
7. **Emergency**
   - The owner can call `emergencyWithdraw()` to withdraw all funds if needed.

---

## 🔒 Best Practices Applied

- Short revert messages (`"Zero"`, `"TooLow"`, etc.).
- No storage reads/writes repeated in loops.
- `require()` placed at top of functions.
- Auction timing is handled safely.
- Prevents reentrancy by updating state before transfers.
- Clean variable handling (dirty variables for loop control).
- Code and documentation fully in English.

---

## 📜 License

This project is licensed under the MIT License.
