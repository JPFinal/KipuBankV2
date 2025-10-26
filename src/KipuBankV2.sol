// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank - Personal ETH vault with secure limits
/// @author Juan
/// @notice Allows users to deposit and withdraw ETH with per-user and global limits
contract KipuBank {
    /// @notice Global deposit cap for the contract
    /// @dev Immutable, set at deployment
    uint256 public immutable bankCap;

    /// @notice Maximum withdrawal allowed per transaction
    /// @dev Immutable, set at deployment
    uint256 public immutable withdrawLimit;

    /// @notice Total ETH deposited across all users
    uint256 public totalDeposited;

    /// @notice Total number of deposit operations
    uint256 public depositCount;

    /// @notice Total number of withdrawal operations
    uint256 public withdrawalCount;

    /// @notice Mapping of user vault balances
    mapping(address => uint256) private vaults;

    /// @notice Emitted when a user successfully deposits ETH
    /// @param user Address of the depositor
    /// @param amount Amount deposited in wei
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a user successfully withdraws ETH
    /// @param user Address of the withdrawer
    /// @param amount Amount withdrawn in wei
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Reverts if deposit exceeds global cap
    error DepositLimitReached();

    /// @notice Reverts if withdrawal exceeds per-transaction limit
    error WithdrawLimitExceeded();

    /// @notice Reverts if user has insufficient balance
    error InsufficientBalance();

    /// @dev Modifier to ensure deposit does not exceed global cap
    /// @param amount Amount being deposited
    modifier withinBankCap(uint256 amount) {
        if (totalDeposited + amount > bankCap) revert DepositLimitReached();
        _;
    }

    /// @notice Initializes the contract with deposit and withdrawal limits
    /// @param _bankCap Maximum total deposits allowed
    /// @param _withdrawLimit Maximum withdrawal per transaction
    constructor(uint256 _bankCap, uint256 _withdrawLimit) {
        bankCap = _bankCap;
        withdrawLimit = _withdrawLimit;
    }

    /// @notice Allows users to deposit ETH into their personal vault
    /// @dev Uses checks-effects-interactions pattern
    function deposit() external payable withinBankCap(msg.value) {
        uint256 amount = msg.value;
        vaults[msg.sender] += amount;
        totalDeposited += amount;
        depositCount++;
        emit Deposited(msg.sender, amount);
    }
    /// @notice Allows users to withdraw ETH from their vault within the allowed limit
    /// @param amount Amount to withdraw in wei
    function withdraw(uint256 amount) external {
        uint256 userBalance = vaults[msg.sender];

        if (amount > withdrawLimit) revert WithdrawLimitExceeded();
        if (userBalance < amount) revert InsufficientBalance();

        vaults[msg.sender] = userBalance - amount;
        totalDeposited -= amount;
        withdrawalCount++;
        emit Withdrawn(msg.sender, amount);
        _safeTransfer(msg.sender, amount);
    }

    /// @notice Returns the current vault balance of a user
    /// @param user Address to query
    /// @return Balance in wei
    function viewVault(address user) external view returns (uint256) {
        return vaults[user];
    }

    /// @dev Performs a safe ETH transfer using call
    /// @param to Recipient address
    /// @param amount Amount to transfer in wei
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
