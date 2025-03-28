Lab 3: AMM DEX ("Build-your-own-Uniswap" Lab)
===

Introduction
---

In today's DEX market, Uniswap is the most popular service at all time. The DEX market distribution on Ethereum can be seen in the following screenshot from https://etherscan.io/stat/dextracker.

![DEX market](dex-market-uniswapv2.png)

In this lab, you will write smart contracts to implement your own version of Uniswap V3. Uniswap adopts the automated market maker (AMM) protocol in which a trader trades directly with a smart-contract intermediary called pool. This is unlike other DEX designs like order books. Besides Uniswap V3, AMM has also been adopted in other popular services, including Uniswap V2, Sushiswap, Pancakeswap, etc.

| Tasks | Points | Undergraduate student | Master student |
| --- | --- | --- | --- |
|  1  | 10 | Required | Required |
|  2  | 20 | Required | Required |
|  3  | 30 | Required | Required |
|  4  | 40 | Required | Required |
|  5  | 10 | Bonus    | Required |

Exercise 1. Execute ERC20 token transfer
---

The following smart contract implements a very simple token supporting the essential transfer function: `transfer(address recipient, uint256 amount)` 

```
// SPDX-License-Identifier: BADD Labs

pragma solidity >=0.7.0 <0.9.0; 
contract BaddToken {  
  uint _totalSupply = 0; string _symbol;  
  mapping(address => uint) balances;  
  constructor(string memory symbol, uint256 initialSupply) {
    _symbol = symbol;
    _totalSupply = initialSupply;
    balances[msg.sender] = _totalSupply;  
  }
  
  function transfer(address receiver, uint amount) public returns (bool) {    
    require(amount <= balances[msg.sender]);        
    balances[msg.sender] = balances[msg.sender] - amount;    
    balances[receiver] = balances[receiver] + amount;    
    return true;  
  }

  function balanceOf(address account) public view returns(uint256){
    return balances[account];
  }}
```

Your job in this exercise is to deploy the above `BaddToken` SC and create a Token instance, say `TokenX`. Then, demonstrate the process that the `TokenX` issuer transfers 10 `TokenX` to another account, say Alice, and display each account's balance before/after the transfer.

**Note:** If you cannot deploy the above token contract on Remix due to an error of "invalid opcode", you may need to select the compiler version of "0.8.19+commit" in the compilation step and then select the environment of "Remix VM (Shanghai)" in the Deploy & Run step.

**Submission guideline:** You should take screenshots to show the balance of each account before and after the token transfer.  

Exercise 2. Extend `BaddToken` with approve/transferFrom
---

```
function approve(address spender, uint256 amount) external returns (bool)
function allowance(address owner, address spender) external view returns (uint256)
function transferFrom(address from, address to, uint256 amount) external returns (bool)
```

Your job is to extend the `BaddToken` with the `approve` and `transferFrom` functions defined above. For example, suppose owner Alice wants to transfer 1 `BaddToken` to another account Bob, through an intermediary Charlie. Alice first calls `approve(Charlie,1)` which gives Charlie an allowance of 1 `BaddToken`. Here, allowance is the amount of the tokens original owner Alice delegate to a third-party spender account Charlie, so that Charlie can spend them on behalf of Alice. Then, Charlie calls the function `transferFrom(Alice,Bob,1)`, through which Bob's balance is credited by 1 `BaddToken` and Alice's balance is debited by 1 `BaddToken`.

Deploy the extended `BaddToken` SC in Remix. We use the following table to test/grade if your deployed token SC is correct. For instance, we may send a sequence of transaction against the instances of your `BaddToken`: `A.approve(C,1)`, `balanceOf(A)`, `allowance(A,C)`, `balanceOf(B)`, `C.transferFrom(A,B,1)`, `balanceOf(B)`. If your SC is correct, we expect the transaction returns the following: ...,`balanceOf(A)=1`, `allowance(A,C)=1`, `balanceOf(B)=0`,...,`balanceOf(B)=1`.

| Calls | `balanceOf(A)` | `balanceOf(B)` | `allowance(A,C)` | 
| --- | --- | --- | --- |
| Init state  | 1 | 0 | 0 |
| `A.approve(C,1)` | 1 | 0 | 1 |
| `C.transferFrom(A,B,1)` | 0 | 1 | 0 |

Hint: You can use nested mapping to store the allowance information, such as `mapping(address account => mapping(address spender => uint256)) private allowances;`. Then you can read or update it with `allowances[owner][spender]`.

**Submission guideline:** You need to submit the smart contract code, which is a solidity file, and name it "exercise2.sol". You also need to take screenshots for each step of the program execution. 

Exercise 3. AMM Design with Fixed Rate
---

![AMM design diagram](lab-amm-tff.png)

The figure above shows the workflow of the fixed-rate AMM you are going to build. Initially, two token contract accounts i.e., `TokenX` and `TokenY` are created by deploying the extended `BaddToken` you built in Exercise 2.

In Step 1, trader Alice approves $x$ units of `TokenX` from her account (EOA) to the AMM `Pool`'s contract account (CA). In Step 2, Alice calls the `Pool`'s function `swapXY(dx)`. Upon receiving Alice's transaction, the `Pool` internally calls `TokenY`'s `transfer` function to transfer $dy$ units of `TokenY` to Alice (Step 3). The `Pool` also internally calls `TokenX`'s `transferFrom` function to transfer Alice's $dx$ units of `TokenX` to the `Pool`,  spending the allowance (Step 4).

In this exercise, you can consider that $dy/dx = 2$. Implement the AMM smart contract using the following interface.

```
// SPDX-License-Identifier: BADD Labs

pragma solidity >=0.7.0 <0.9.0; 
contract AMMPool {
  BaddToken tokenX;
  BaddToken tokenY;
  // _tokenX and _tokenY are contract-addresses running BaddToken SC
  constructor(address _tokenX, address _tokenY){
    tokenX = BaddToken(_tokenX); tokenY = BaddToken(_tokenY);
  }

  function swapXY(uint amountX) public payable {
    // fill out the following with your code
  } 
}
```

You can follow the workflow to execute your code.

- Implement the above `AMMPool` smart contract by filling the function bodies.
- Deploy `BaddToken` smart contract twice, respectively to two contract addresses, say `TokenX` and `TokenY`.
- Deploy `AMMPool` smart contract to create the `Pool` account.
- Execute the smart contracts in two steps: 
    1. call `TokenX`'s `approve` function
    2. call `Pool`'s `swapXY` function

- Hint: You need to ensure your account has enough tokens for both `TokenX` and `TokenY`. 
- Hint 2: If a SC needs to reference itself, you can use `address(this)`.


We will test your pool SC using the following test cases. `P` is the Pool CA, `X` is `TokenX` and `Y` is `TokenY`.

| Calls | `X.balanceOf(A)` | `X.balanceOf(P)` | `X.allowance(A,P)` | `Y.balanceOf(A)` | `Y.balanceOf(P)` |
| --- | --- | --- | --- | ---- | --- |
| Init state  | 1 | 0 | 0 | 0 | 2 |
| `A.approve(P,1)` | 1 | 0 | 1 | 0 | 2 |
| `A.swapXY(1)` | 0 | 1 | 0 | 2 | 0 |

**Submission guideline:** You need to submit the smart contract code, which is a solidity file, and name it "exercise3.sol". You also need to take screenshots for each step of the program execution. 

Exercise 4. Constant-product AMM
---

Suppose the AMM account owns $x$ units of `TokenX` and $y$ units of `TokenY`. The AMM pool can use a function $f(x,y)$ to calculate the exchange rate between `TokenX` and `TokenY` on the fly. Specifically, it enforces that function value is constant before and after each token swap, that is,

$$f(x,y)=f(x+dx,y-dy)$$

In this exercise, you will extend your solution in Exercise 3 to implement constant-product AMM, where $f(x,y)=x\*y$. Modify your AMM smart contract to support the constant-product invariant $x\*y=(x+dx)(y-dy)$.

- Hint: You may want to keep track of token balance $x$ and $y$ in the AMM smart contact by issuing `balanceOf` in each `swapXY` call.

We will test your solution using the following test case:

| Calls | `X.balanceOf(A)` | `X.balanceOf(P)` | `X.allowance(A,P)` | `Y.balanceOf(A)` | `Y.balanceOf(P)` |
| --- | --- | --- | --- | ---- | --- |
| Init state  | 1 | 1 | 0 | 0 | 4 |
| `A.approve(P,1)` | 1 | 1 | 1 | 0 | 4 |
| `A.swapXY(1)` | 0 | 2 | 0 | 2 | 2 |

**Submission guideline:** You need to submit the smart contract code, which is a solidity file, and name it "exercise4.sol". You also need to take screenshots for each step of the program execution. 

Exercise 5. Undo `approve` upon Standalone Deposit 
---

In Exercise 4, consider Alice, who called the `approve` function (the Deposit step) but did not call the `swapXY` (the Withdrawal step). This is possibly due to that Alice changes her mind after the deposit and wants to undo it.

Extend your pool SC from the previous exercises to support undo `approve` and to revert a trade-in-progress. You may want to implement a function in the AMM pool, say `undo_approve()`. After Step 1 and calling `undo_approve()`, Alice will have her original balance in `TokenX` and zero allowance to the pool. That is (`P` is the Pool CA):

| Calls | `X.balanceOf(A)` | `X.balanceOf(P)` | `X.allowance(A,P)` | 
| --- | --- | --- | --- |
| Init state  | 1 | 0 | 0 |
| `A.approve(P,1)` | 1 | 0 | 1 |
| `A.undo_approve()` | 1 | 0 | 0 |

**Submission guideline:** You need to submit the smart contract code, which is a solidity file, and name it "exercise5.sol". You also need to take screenshots for each step of the program execution. 

Deliverables
---
You should submit one document and 4 solidity code files.
- For exercise 1, you should include the screenshot of the program execution in the document.
- For exercise 2-5, you should include the screenshots showing the program execution in the document. You also need to submit the solidity code developed by you.

