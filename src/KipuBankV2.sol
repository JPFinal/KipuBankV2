// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title KipuBankV2 - Multi-token vault with access control and Chainlink integration
/// @author Juan
/// @notice Allows deposits and withdrawals in ETH and ERC-20 tokens with USD-based limits
contract KipuBankV2 is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Chainlink ETH/USD price feed
    AggregatorV3Interface public immutable priceFeed;

    /// @notice USD cap for total deposits (scaled to 6 decimals)
    uint256 public constant BANK_CAP_USD = 1000000 * 10**6; // 1,000,000 USD

    /// @notice Mapping of user balances per token
    mapping(address => mapping(address => uint256)) public balances;

    /// @notice Total deposits per token
    mapping(address => uint256) public totalDeposited;

    /// @notice Emitted when a deposit is made
    event Deposited(address indexed user, address indexed token, uint256 amount);

    /// @notice Emitted when a withdrawal is made
    event Withdrawn(address indexed user, address indexed token, uint256 amount);

    /// @notice Reverts if deposit exceeds USD cap
    error BankCapExceeded();

    /// @notice Reverts if user has insufficient balance
    error InsufficientBalance();

    constructor(address _priceFeed) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /// @notice Deposit ETH into vault
    function depositETH() external payable {
        uint256 normalized = normalizeDecimals(address(0), msg.value);
        if (getTotalUSD() + normalized > BANK_CAP_USD) revert BankCapExceeded();

        balances[msg.sender][address(0)] += msg.value;
        totalDeposited[address(0)] += msg.value;
        emit Deposited(msg.sender, address(0), msg.value);
    }

    /// @notice Withdraw ETH from vault
    /// @param amount Amount to withdraw
    function withdrawETH(uint256 amount) external {
        if (balances[msg.sender][address(0)] < amount) revert InsufficientBalance();

        balances[msg.sender][address(0)] -= amount;
        totalDeposited[address(0)] -= amount;
        emit Withdrawn(msg.sender, address(0), amount);
        _safeTransfer(msg.sender, amount);
    }

    /// @notice Withdraw ERC-20 token from vault
    /// @param token Address of the token
    /// @param amount Amount to withdraw
    function withdrawToken(address token, uint256 amount) external {
        if (balances[msg.sender][token] < amount) revert InsufficientBalance();

        balances[msg.sender][token] -= amount;
        totalDeposited[token] -= amount;
        emit Withdrawn(msg.sender, token, amount);
        IERC20(token).transfer(msg.sender, amount);
    }

    /// @notice Normalize token amount to 6 decimals (USDC standard)
    /// @param token Address of the token
    /// @param amount Original amount
    /// @return Normalized amount
    function normalizeDecimals(address token, uint256 amount) internal view returns (uint256) {
        if (token == address(0)) return convertETHtoUSD(amount);
        uint8 decimals = IERC20Metadata(token).decimals();
        if (decimals > 6) return amount / (10 ** (decimals - 6));
        else return amount * (10 ** (6 - decimals));
    }

    /// @notice Convert ETH amount to USD using Chainlink
    /// @param amount ETH amount in wei
    /// @return USD value scaled to 6 decimals
    function convertETHtoUSD(uint256 amount) public view returns (uint256) {
        (, int price,,,) = priceFeed.latestRoundData(); // ETH/USD with 8 decimals
        require(price > 0, "Invalid price");
        return (amount * uint256(price)) / 1e20; // Convert wei to USD with 6 decimals
    }

    /// @notice Get total USD value across all tokens
    /// @return Total USD value scaled to 6 decimals
    function getTotalUSD() public view returns (uint256) {
        uint256 ethUSD = convertETHtoUSD(totalDeposited[address(0)]);
        // Extend to include ERC-20 tokens if needed
        return ethUSD;
    }

    /// @dev Safe ETH transfer using call
    function _safeTransfer(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
