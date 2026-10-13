# Lab A2 Write-up

**Name:**
**CWID:**
**Undergraduate / Graduate:**

> Fill in each section below. Paste terminal output inside the fenced code blocks.
> Keep answers short — a few sentences each is plenty.

---

## Exercise 1 — Hello world

### Deployment and `cast` transcript

```text
(paste your output from `forge script script/Ex1Deploy.s.sol ...`
 and your `cast call` / `cast send` commands here)
```

### Question

`cast call` costs you nothing and `cast send` costs gas. What is the difference
between the two, and why does reading contract state not require a transaction?

**Answer:**

---

## Exercise 2 — Bigger of two numbers

### Test result

```text
(paste the output of `forge test --match-contract Ex2MaxTest`)
```

### Question

One of the property tests catches a class of bug that the three required cases
(`x < y`, `x = y`, `x > y`) cannot. Which test, and what bug?

**Answer:**

---

## Exercise 3 — Single-account Ether bank

### Demo transcript

```text
(paste your output from `forge script script/Ex3BankDemo.s.sol ...`)
```

### Question 1

After the relay, the ledger still reads 10 ETH and the contract still holds 10 ETH,
but Bob is 20 ETH richer. Where did that 20 ETH go, and why did the ledger not
change?

**Answer:**

### Question 2

The state variable is called `etherBalanceAlice`. What in the code enforces that it
belongs to Alice?

**Answer:**

### Question 3

`test_AnyoneCanDrainAlicesDeposit` shows a stranger withdrawing Alice's deposit and
the contract allowing it. In one sentence, what is missing?

**Answer:**

### Question 4

`getBalanceEOA()` returns `msg.sender.balance`. Explain why calling it tells you
about the caller, not about the bank.

**Answer:**

---

## Exercise 4 — Two-account Ether bank

### Test result

```text
(paste the output of `forge test --match-contract Ex4TwoAccountBankTest`)
```

### Question

Explain why reverting is sufficient to guarantee that a failed withdrawal leaves
every balance unchanged, with no refund code of your own.

**Answer:**

### Checks → effects → interactions

Paste the three key lines of your `withdraw`, in order, and label them:

```solidity
// check:
// effect:
// interaction:
```

---

## Exercise 5 — Refusing unknown deposits

> Bonus for undergraduates. Required for graduate students.

### Test result

```text
(paste the output of `forge test --match-contract Ex5GuardedBankTest`)
```

### Question

Explain why requirement 5 (the contract's balance is unchanged after a rejected
transfer) follows automatically from how you implemented requirements 2 and 3.

**Answer:**

---

## Final check

```text
(paste the output of `forge clean && forge build && forge test`)
```
