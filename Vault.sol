// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Vault {
    IERC20 public immutable token;
    uint public totalSupply;
    uint public reward;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public rewards;

    constructor(address _token) {
        token = IERC20(_token);
    }

    // Private function to mint shares
    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    // Private function to burn shares
    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    // Deposit tokens and mint shares
    function deposit(uint _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
    }

    // Withdraw tokens by burning shares
    function withdraw(uint _shares) external {
        require(_shares > 0, "Shares must be greater than zero");
        require(balanceOf[msg.sender] >= _shares, "Insufficient shares");

        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        require(token.transfer(msg.sender, amount), "Transfer failed");

        reward = calculateReward(amount);
        rewards[msg.sender] += reward;
    }

    // Calculate reward based on amount
    function calculateReward(uint _amount) private pure returns (uint) {
        return _amount / 100; // 1% reward
    }

    // Redeem accumulated rewards
    function redeemReward() external {
        uint amount = rewards[msg.sender];
        require(amount > 0, "No rewards to redeem");

        _mint(msg.sender, amount);
        rewards[msg.sender] = 0;
    }
}
