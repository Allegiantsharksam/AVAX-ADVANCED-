# Creating a DeFi Kingdom Clone on Avalanche

In this Solidity program, we create our own custom subnet on Avalanche and deploy foundational smart contracts to build a DeFi Kingdom clone.

## Description

In this project, we first create our own custom subnet on Avalanche and deploy it. In the custom subnet, we create our native currency which 
we can later use for transactions. Then we connect the subnet to MetaMask. After that, we have two smart contracts - `ERC20.sol` and `Vault.sol`. 
These two contracts are the basic building blocks of our game. The `ERC20` contract is used to add the functionalities of the ERC20 token. The 
`Vault` contract is used to define the game rules and functions like depositing tokens, withdrawing tokens, redeeming rewards, and checking account 
balances.

## Getting Started

### Executing Program

To execute this project, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at [Remix](https://remix.ethereum.org/).

1. **Create and Deploy ERC20 Contract:**

   - Create a new file by clicking on the "+" icon in the left-hand sidebar.
   - Save the file as `ERC20.sol`.
   - Copy and paste the following code into the `ERC20.sol` file:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.17;

   contract ERC20 {
       uint public totalSupply;
       mapping(address => uint) public balanceOf;
       mapping(address => mapping(address => uint)) public allowance;
       string public name = "Allegiant Shark";
       string public symbol = "Sparsh";
       uint8 public decimals = 18;

       // Events
       event Transfer(address indexed from, address indexed to, uint value);
       event Approval(address indexed owner, address indexed spender, uint value);

       // Transfer tokens from the caller's account to the recipient
       function transfer(address recipient, uint amount) external returns (bool) {
           require(balanceOf[msg.sender] >= amount, "Insufficient balance");
           balanceOf[msg.sender] -= amount;
           balanceOf[recipient] += amount;
           emit Transfer(msg.sender, recipient, amount);
           return true;
       }

       // Approve the spender to spend up to 'amount' from the caller's account
       function approve(address spender, uint amount) external returns (bool) {
           allowance[msg.sender][spender] = amount;
           emit Approval(msg.sender, spender, amount);
           return true;
       }

       // Transfer tokens from one account to another, if allowed
       function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
           require(balanceOf[sender] >= amount, "Insufficient balance");
           require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
           allowance[sender][msg.sender] -= amount;
           balanceOf[sender] -= amount;
           balanceOf[recipient] += amount;
           emit Transfer(sender, recipient, amount);
           return true;
       }

       // Mint new tokens to the caller's account
       function mint(uint amount) external {
           balanceOf[msg.sender] += amount;
           totalSupply += amount;
           emit Transfer(address(0), msg.sender, amount);
       }

       // Burn tokens from the caller's account
       function burn(uint amount) external {
           require(balanceOf[msg.sender] >= amount, "Insufficient balance");
           balanceOf[msg.sender] -= amount;
           totalSupply -= amount;
           emit Transfer(msg.sender, address(0), amount);
       }
   }
   ```

2. **Create and Deploy Vault Contract:**

   - Similarly, create another file in the same folder as `Vault.sol`.
   - Copy and paste the following code into the `Vault.sol` file:

   ```solidity
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
   ```

3. **Setup and Deployment:**

   - Set the environment in the Remix IDE to the injected provider (MetaMask) and connect it to the custom EVM subnet you created.
   - Deploy the `ERC20` contract and copy its contract address.
   - Deploy the `Vault` contract, providing the `ERC20` contract address in the constructor.
   - Mint some tokens in the `ERC20` contract using the `mint` function.
   - Approve the `Vault` contract to spend tokens using the `approve` function in the `ERC20` contract.

4. **Interact with the Smart Contracts:**

   - **Deposit:** Enter the amount you wish to deposit and click "Deposit".
   - **Withdraw:** Enter the amount of shares you wish to withdraw and click "Withdraw".
   - **BalanceOf:** Enter your account address and click on "BalanceOf" to check the balance of your account.
   - **Rewards:** Enter your account address and click on "Rewards" to check the rewards you have.
   - **RedeemRewards:** Click on "RedeemRewards" to redeem the rewards that you have.

By following these steps, you can create and deploy your own DeFi Kingdom clone on Avalanche, utilizing the provided smart contracts.

## Authors

Contributors names and contact info:
- Sparsh Shandil
- [@Allegiantshark](https://linktr.ee/allegiantshark)

## License

This project is licensed under the Sparsh Shandil License - see the LICENSE.md file for details.

This `README.md` file includes detailed instructions on setting up and deploying the ERC20 and Vault smart contracts using Remix, as 
well as interacting with them. The provided code snippets are adjusted to match the ERC20 contract with the specified token name "Allegiant Shark" 
and symbol "Sparsh".
