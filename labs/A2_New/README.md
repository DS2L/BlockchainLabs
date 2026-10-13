# Lab A2 — Smart Contract Programming

**CS 810 · Blockchain Labs**

Build, test, and run Solidity smart contracts on your own machine. You will write a
small Ether bank and make it refuse the transactions it ought to refuse.

Everything in this lab runs locally. There is no browser IDE, no screenshots, and
no shared testnet. Your work is graded by a test suite you can run as often as you
like, before you submit.

---

## Table of contents

- [What you need](#what-you-need)
- [Setup](#setup)
- [How this lab works](#how-this-lab-works)
- [Exercise 1 — Hello world (15 pts)](#exercise-1--hello-world-15-pts)
- [Exercise 2 — Bigger of two numbers (25 pts)](#exercise-2--bigger-of-two-numbers-25-pts)
- [Exercise 3 — Single-account Ether bank (25 pts)](#exercise-3--single-account-ether-bank-25-pts)
- [Exercise 4 — Two-account Ether bank (35 pts)](#exercise-4--two-account-ether-bank-35-pts)
- [Exercise 5 — Refusing unknown deposits (10 pts)](#exercise-5--refusing-unknown-deposits-10-pts)
- [Submission](#submission)
- [Grading](#grading)
- [Solidity 0.4 → 0.8: what changed](#solidity-04--08-what-changed)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

---

## What you need

- A terminal — macOS, Linux, or Windows via WSL2.
- `git` and `curl`.
- About 10 minutes for the one-time install.

You do **not** need an Ethereum account, test Ether, a wallet, a faucet, or an
internet connection after setup. You will run your own blockchain.

---

## Setup

### 1. Install Foundry

Foundry is the toolchain for this lab. It is a single install that gives you four
commands:

| Command  | What it does                                               |
| -------- | ---------------------------------------------------------- |
| `forge`  | Compiles contracts and runs tests                          |
| `anvil`  | Runs a local Ethereum node on your machine                 |
| `cast`   | Sends transactions and reads contract state from the shell |
| `chisel` | A Solidity REPL for trying out one-liners                  |

```bash
curl -L https://foundry.paradigm.xyz | bash
# then restart your shell, or run the `source` line it prints
foundryup
```

Verify:

```bash
forge --version
```

> **Windows:** install [WSL2](https://learn.microsoft.com/windows/wsl/install) and
> run everything inside your Linux shell. Foundry on native Windows is not
> supported for this lab.

### 2. Get the lab

```bash
git clone --recurse-submodules https://github.com/DS2L/BlockchainLabs.git
cd BlockchainLabs/labs/A2_New
```

If you cloned without `--recurse-submodules`, fetch the test library:

```bash
git submodule update --init --recursive
```

> **Run every command in this lab from `labs/A2-foundry/`.** That directory is the
> project root — `forge` looks for `foundry.toml` in the directory you are standing
> in, so running it from the repository root will not work.

### 3. Confirm your setup works

```bash
forge build
forge test --match-contract Ex1HelloTest
```

The first `forge build` downloads the pinned Solidity compiler (0.8.30) and takes a
minute. After that, it is fast.

You should see **5 passing tests**. If you do, your toolchain is correct, and you can
start. If you do not, see [Troubleshooting](#troubleshooting) before going further.

---

## How this lab works

The lab is laid out like a real Solidity project:

```
labs/A2-foundry/
├── src/                 ← the contracts. Your work goes here.
│   ├── Ex1Hello.sol            given, complete — do not modify
│   ├── Ex2Max.sol              ← you implement
│   ├── Ex3Bank.sol             given, complete — do not modify
│   ├── Ex4TwoAccountBank.sol   ← you implement
│   └── Ex5GuardedBank.sol      ← you implement
├── test/                ← the test suite. This is your specification.
├── script/              ← deploy-and-run scripts for the local chain
├── lib/forge-std/       ← testing library (submodule)
├── foundry.toml         ← project + compiler configuration
└── WRITEUP.md           ← ← you fill this in
```

**The tests are the assignment.** `test/` contains the complete, visible
specification of what every contract must do — the same suite used for grading.
Nothing is hidden. If `forge test` is green, your implementation is correct.

Read the test file for an exercise before you write any code. A test name like
`test_FailedWithdrawalChangesNothing` tells you a requirement more precisely than a
paragraph of prose can.

### The commands you will use

```bash
forge build                                 # compile everything
forge test                                  # run every test
forge test --match-contract Ex4TwoAccountBankTest   # run one exercise
forge test --match-test test_AliceCannotOverdraw    # run one test
forge test -vv                              # show console logs
forge test -vvvv                            # show full call traces — use this to debug
forge fmt                                   # auto-format your Solidity
```

`-vvvv` is the one worth remembering. When a test fails, it prints every call,
every argument, and the exact revert — far more than a screenshot of a failed Remix
transaction ever showed you.

---

## Exercise 1 — Hello world (15 pts)

**You write no contract code.** This exercise proves your toolchain works and
introduces the two ways you will interact with contracts.

`src/Ex1Hello.sol` stores a string and reads it back.

### Step 1 — Run the tests

```bash
forge test --match-contract Ex1HelloTest -vv
```

All 5 should pass.

### Step 2 — Start a local blockchain

In a **second terminal**, leave this running:

```bash
anvil
```

`anvil` prints ten funded accounts with their private keys and listens on
`http://127.0.0.1:8545`. These keys are publicly known test keys. They are worthless.
Never use them on a real network.

### Step 3 — Deploy to it

Back in your first terminal:

```bash
forge script script/Ex1Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Note the deployed address it prints.

### Step 4 — Talk to it by hand

This is the command-line equivalent of clicking the buttons in a browser IDE:

```bash
# read the stored greeting
cast call <ADDRESS> 'greet()(string)' --rpc-url http://127.0.0.1:8545

# write a new one (account #0's key, printed by anvil)
cast send <ADDRESS> 'greeter(string)' 'my own greeting' \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# read it back
cast call <ADDRESS> 'greet()(string)' --rpc-url http://127.0.0.1:8545
```

**In `WRITEUP.md`:** paste your terminal transcript from steps 3 and 4, and answer:
`cast call` costs you nothing and `cast send` costs gas. What is the difference
between the two, and why does reading state not require a transaction?

---

## Exercise 2 — Bigger of two numbers (25 pts)

Implement `max` in `src/Ex2Max.sol` so it returns the larger of two signed integers.

```bash
forge test --match-contract Ex2MaxTest -vv
```

The original version of this lab asked for three screenshots: `x < y`, `x = y`, and
`x > y`. The test suite checks those three, and then checks the cases three
screenshots would let you miss — negative numbers, mixed signs, and the extremes of
`int256`. It also runs three **property tests** over 256 random input pairs each:
the result must be one of the inputs, must be at least as large as both, and must
not depend on argument order.

Watch the types. These are `int256`, not `uint256`. A tempting solution built around
subtraction will pass the three required cases and then fail `test_Extremes`.

**In `WRITEUP.md`:** one of the property tests catches a class of bug the three
required cases cannot. Which one, and what bug?

---

## Exercise 3 — Single-account Ether bank (25 pts)

**You write no contract code.** You run a bank that is given to you, observe what it
does, and explain what is wrong with it.

`src/Ex3Bank.sol` is a bank that tracks a balance for one customer, Alice. It has
`deposit`, `withdraw`, `relay`, `getBalanceCA`, and `getBalanceEOA`.

### Step 1 — Read the contract

Before running anything, read `src/Ex3Bank.sol` and predict what each function does.

### Step 2 — Run the tests

```bash
forge test --match-contract Ex3BankTest -vv
```

All 8 pass — the contract does what it was written to do. Read the last two tests
carefully. They pass, and that is the problem.

### Step 3 — Run it on a live chain

With `anvil` running in your second terminal:

```bash
forge script script/Ex3BankDemo.s.sol --rpc-url http://127.0.0.1:8545 --broadcast -vv
```

This performs the exact sequence the old version of this lab asked you to
screenshot — Alice deposits 10 ETH, then relays 20 ETH to Bob — and prints the
ledger balance, the contract account balance, and both EOA balances after every
step.

**In `WRITEUP.md`:** paste the printed transcript and answer:

1. After the relay, the ledger still reads 10 ETH and the contract still holds
   10 ETH, but Bob is 20 ETH richer. Where did that 20 ETH go, and why did the
   ledger not change?
2. The state variable is called `etherBalanceAlice`. What in the code enforces that
   it belongs to Alice? (See `test_AnyoneCanDepositIntoAlicesAccount`.)
3. `test_AnyoneCanDrainAlicesDeposit` shows a stranger withdrawing Alice's deposit
   and the contract allowing it. In one sentence, what is missing?
4. `getBalanceEOA()` returns `msg.sender.balance`. Explain why calling it tells you
   about the *caller*, not about the bank.

Your answer to question 3 is what you implement in Exercise 4.

---

## Exercise 4 — Two-account Ether bank (35 pts)

Implement `src/Ex4TwoAccountBank.sol`: a bank with two customers, Alice and Bob,
where each can withdraw only their own money.

```bash
forge test --match-contract Ex4TwoAccountBankTest -vv
```

### Requirements

1. `deposit()` credits `msg.value` to the caller's balance. Anyone may deposit in
   this exercise — Exercise 5 changes that.
2. `withdraw(amount)` succeeds only when the **caller's own** balance is at least
   `amount`, then debits them and sends the Ether.
3. A failed withdrawal leaves every balance exactly as it was.
4. `balanceOf(account)` reports the ledger balance for `account`.
5. Alice withdrawing never touches Bob's balance, and vice versa.

Keep the signatures of `deposit`, `withdraw`, and `balanceOf` — the tests call them
by name. Everything else is yours: add state, events, custom errors, modifiers,
helpers as you see fit.

The test suite checks the scenario table from the original lab (Alice deposits 5,
Bob deposits 3, Charlie deposits nothing) and then fuzzes deposit/withdraw pairs
over 256 random amounts.

### Two things worth getting right

**Reverting is the mechanism for requirement 3.** When a transaction reverts, the
EVM discards *every* state change it made, including the Ether movement. You do not
need to undo anything by hand. Writing refund logic is a sign you have reached for
the wrong tool.

**Order your withdrawal as checks → effects → interactions.** Validate first, update
your ledger second, send Ether last. The tests here pass either way, but Lab B3 is
about reentrancy, and this is the habit that prevents it. Start now.

**In `WRITEUP.md`:** explain why reverting is sufficient for requirement 3, and show
the three lines of your `withdraw` in checks-effects-interactions order.

---

## Exercise 5 — Refusing unknown deposits (10 pts)

> Bonus for undergraduates. Required for graduate students.

Start from your Exercise 4 solution and add one rule to `src/Ex5GuardedBank.sol`:
only Alice and Bob may put Ether into this bank. Charlie must be turned away.

```bash
forge test --match-contract Ex5GuardedBankTest -vv
```

Charlie has two ways to push Ether at a contract, and you must block both:

**(a) Calling `deposit()` explicitly.** Guard the function.

**(b) A plain Ether transfer with empty calldata** — no function named at all. This
never reaches `deposit()`. It reaches `receive()`, a special function that did not
exist in Solidity 0.4.x, where a single nameless `function() payable` fallback
handled both cases.

### Requirements

1. Everything Exercise 4 required still holds.
2. `deposit()` from anyone other than Alice or Bob reverts.
3. A plain Ether transfer from anyone other than Alice or Bob reverts.
4. A plain transfer **from Alice or Bob succeeds** and credits the sender, exactly as
   if they had called `deposit()`.
5. After a rejected transfer, the contract's Ether balance is unchanged.

Requirement 4 is the one that makes this exercise real. Deleting `receive()`
entirely blocks Charlie — and blocks Alice too. There is a passing solution and a
lazy solution, and the tests tell them apart.

### A note on gas

The tests send plain transfers with a low-level `call`, which forwards all remaining
gas. Older tutorials use `.transfer()` and `.send()`, which forward only 2300 gas —
not enough to write a storage slot. A `receive()` that does real bookkeeping cannot
be reached by them at all. This is why modern Solidity uses `call` with an explicit
success check, as `Ex3Bank` does.

**In `WRITEUP.md`:** explain why requirement 5 follows automatically from how you
implemented requirements 2 and 3, without any refund code.

---

## Submission

Submit to the **Lab A2 assignment on Canvas**. Upload exactly these four files:

| File | What it is |
| --- | --- |
| `src/Ex2Max.sol` | your Exercise 2 implementation |
| `src/Ex4TwoAccountBank.sol` | your Exercise 4 implementation |
| `src/Ex5GuardedBank.sol` | your Exercise 5 implementation |
| `WRITEUP.md` | your transcripts and written answers |

Upload them as four separate files. **Keep the original filenames** — they are how
your work gets matched to the right exercise.

> Graduate students: all four files.
> Undergraduates: `Ex5GuardedBank.sol` is the bonus. Submit it if you attempted it,
> skip it if you did not.

### Do not submit

- **The whole project folder or a zip of it.** Your three contracts are dropped into
  a fresh copy of this lab and run against the original test suite, so `test/`,
  `lib/`, and `foundry.toml` are not needed and will be ignored.
- **`out/`, `cache/`, or `broadcast/`.** Build artifacts, regenerated on every build.

Editing the files in `test/` changes nothing about your grade — grading always uses
the original suite. If you want to experiment with the tests to understand them,
go ahead; just do not expect it to count.

### Before you upload

Run the suite one last time from a clean state:

```bash
forge clean && forge build && forge test
```

Two things to confirm in that output:

1. **It compiles.** A contract that does not compile scores zero for its exercise,
   and `forge clean` catches the case where a stale `out/` was hiding a broken build.
2. **The failures you see are only in exercises you chose not to attempt.** Anything
   else is still worth fixing before you submit.

---

## Grading

| Exercise | Points | Undergrad | Grad     | Graded on                                  |
| -------- | -----: | --------- | -------- | ------------------------------------------ |
| 1        |     15 | Required  | Required | `WRITEUP.md`: transcript + 1 answer        |
| 2        |     25 | Required  | Required | `Ex2MaxTest` — 10 tests                    |
| 3        |     25 | Required  | Required | `WRITEUP.md`: transcript + 4 answers       |
| 4        |     35 | Required  | Required | `Ex4TwoAccountBankTest` — 15 tests         |
| 5        |     10 | **Bonus** | Required | `Ex5GuardedBankTest` — 13 tests            |

**Exercises 2, 4, and 5 (80 points)** are scored by running the test suite against
your contracts. Points are proportional to tests passed, so partial work earns
partial credit — a solution that handles the ordinary cases but misses the extremes
still scores.

**Exercises 1 and 3 (40 points)** are scored from your write-up. You write no
contract code for these, and their tests pass for everyone from the moment you clone
the lab, so passing them is not evidence of anything. What is being graded is
whether you ran the programs and understood what you saw.

Contracts that fail to compile score zero for that exercise, since no test can run
against them. `forge build` is the first thing done when grading, so make it the
last thing you do before uploading.

---

## Solidity 0.4 → 0.8: what changed

This lab previously used Solidity 0.4.13–0.4.25. The contracts here are 0.8.30. If
you find an older tutorial, blog post, or AI-generated answer, these are the
differences that will bite you.

| Topic             | Solidity 0.4.x                       | Solidity 0.8.x                                   |
| ----------------- | ------------------------------------ | ------------------------------------------------ |
| Constructor       | `function Bank() public`             | `constructor()`                                  |
| Overflow          | Wraps silently; needs SafeMath       | Reverts automatically                            |
| Data location     | Optional on parameters               | `memory` / `calldata` required                   |
| Sending Ether     | `address` is implicitly payable      | Needs `address payable` / `payable(addr)`        |
| Receiving Ether   | One nameless `function() payable`    | `receive()` and `fallback()`, separately         |
| Preferred send    | `.transfer()`                        | `.call{value: x}("")` with a checked return      |
| Errors            | `throw`, then `require` with strings | `require` with strings, or custom `error` types  |
| Declaring intent  | `constant`                           | `view` / `pure`                                  |

Two of these are worth understanding rather than memorizing:

**Checked arithmetic.** Before 0.8.0, `uint256 x = 0; x - 1;` silently produced
2²⁵⁶−1, and a bank written this way could be drained by withdrawing more than you
had. Entire contracts existed to prevent it. Since 0.8.0 that expression reverts.
Your Exercise 4 `withdraw` still needs its balance check — but the check is now
about giving a clear error, not about preventing a catastrophe.

**`receive()` vs. the old fallback.** Splitting the nameless fallback into
`receive()` (empty calldata) and `fallback()` (unmatched function selector) made the
two cases distinguishable. Exercise 5 depends on that distinction: `deposit()` and a
plain transfer are genuinely different entry points, and guarding one does nothing
for the other.

---

## Troubleshooting

**`forge: command not found`**
Restart your shell, or run the `source ~/.bashrc` line that the installer printed,
then `foundryup`.

**``Error: contract source info format must be `<path>:<contractname>` or `<contractname>` ``**
You are standing in a subdirectory such as `src/` or `test/`. `forge script`
resolves the script path relative to your current directory, *not* to the project
root, so `script/Ex1Deploy.s.sol` does not exist from inside `test/`. Having failed
to find a file there, forge tries to read the argument as a contract name and gives
up with this message.

`cd` back to the lab's project root — the directory that contains `foundry.toml` —
and re-run:

```bash
cd ~/path/to/BlockchainLabs/labs/A2-foundry
forge script script/Ex1Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

If you would rather not move, either form also works from any subdirectory:

```bash
forge script ../script/Ex1Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
forge script Ex1Deploy --rpc-url http://127.0.0.1:8545 --broadcast   # by contract name
```

**`Error: No such file or directory (os error 2)` or "could not find foundry.toml"**
You are in the wrong directory. Every command must be run from
`BlockchainLabs/labs/A2-foundry/`, not from the repository root.

**`tcp connect error` / `Connection refused (os error 111)`**
Nothing is listening on `http://127.0.0.1:8545`. Start `anvil` in a second terminal
and leave it running, then re-run the script. Note that forge attempts the RPC
connection *before* it resolves the script path, so this error can mask the
directory problem above — fix the connection first, then re-read the next error.

**`failed to resolve file: lib/forge-std/src/Test.sol`**
The submodule is missing: run `git submodule update --init --recursive` from the
repository root.

**First `forge build` hangs or fails to download the compiler**
It is fetching solc 0.8.30. On a restricted campus network this can fail. Try a
different network, or install solc separately and point Foundry at it with
`forge build --use <path-to-solc>`.

**A test fails and I cannot tell why**
Re-run that one test with full traces:

```bash
forge test --match-test test_TheFailingOne -vvvv
```

You get every call, every argument, and the exact revert reason.

**`EvmError: Revert` with no message**
Something reverted without a reason string — often a failed Ether transfer or an
unimplemented stub. The `-vvvv` trace shows which call it was.

**My contract compiles but `balanceOf` returns 0 for everyone**
You are probably crediting a mapping keyed on something other than `msg.sender`, or
reading a different mapping than you write. Add `console2.log` and run with `-vv`:

```solidity
import {console2} from "forge-std/console2.sol";
console2.log("crediting", msg.sender, msg.value);
```

**Tests pass locally but the grader disagrees**
Run `forge clean && forge build && forge test`. Stale artifacts in `out/` are the
usual cause.

---

## Reference

- [Foundry Book](https://book.getfoundry.sh/) — the toolchain manual
- [Forge Standard Library cheatcodes](https://book.getfoundry.sh/cheatcodes/) — `vm.prank`, `vm.deal`, `vm.expectRevert`
- [Solidity docs (current)](https://docs.soliditylang.org/en/latest/) — use this, not the 0.4.24 docs
- [Solidity by Example](https://solidity-by-example.org/) — short, current, runnable

### Cheatcodes you will see in the tests

| Cheatcode                  | What it does                                         |
| -------------------------- | ---------------------------------------------------- |
| `vm.prank(addr)`           | Next call comes from `addr`                          |
| `vm.startPrank` / `stopPrank` | All calls in between come from `addr`             |
| `vm.deal(addr, amount)`    | Sets `addr`'s Ether balance                          |
| `vm.expectRevert()`        | The next call must revert, or the test fails         |
| `makeAddr("name")`         | A deterministic labelled address for readable traces |
| `vm.assume(cond)`          | Discards fuzz inputs that do not satisfy `cond`      |

These replace what you used to do by hand: switching accounts in a dropdown and
hoping you remembered which one was selected.

---

*Adapted from labs by Dr. Yuzhe Tang's team at Syracuse University.*
