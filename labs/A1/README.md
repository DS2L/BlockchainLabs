Lab A1: Transaction History Exploration
===

Introduction
---

Etherscan (https://etherscan.io/) provides a web service to explore Ethereum transactions and blocks. In this lab, you will retrieve and analyze Ethereum transaction history on etherscan by interacting with this website. Particularly, you will extract insights on transaction fees.

| Exercises  | Graduate student (Points) |  Undergraduate student (Points)
| --- | --- | --- |
|  1  | Required (10) | Required (10) |
|  2  | Required (10) | Required (10) | 
|  3  | Required (10) | Required (10) |
|  4  | Required (20) | Required (20) |
|  5  | Required (20) | Required (30) |
|  6  | Required (20) | Required (20) |
|  7  | Required (10) | Bonus    (10) |

Exercise 1. Manually explore three transactions
---

Suppose the following Etherscan page shows details of a particular transaction (hash 0x84ae):

https://etherscan.io/tx/0x84aee3793659afeebfb89b86e6a8ffd3b9f143b3719c9b358905a83dbd71cb79

You are asked to report the average fees of three transactions, that is, transaction 0x84ae, its predecessor transaction and successor transaction. Transaction tx1 is the predecessor of tx2, if tx1 is ordered right before tx2 in the same block.

Hint: You can find ordered transaction history related to block `15479087` on the following web page: https://etherscan.io/txs?block=15479087

Exercise 2. Manually explore one block
---

Find the transaction that transfers the highest Ether "value" in block `15479087`. Report the transaction hash. 

Exercise 3. Manually explore two blocks
---

Find the last transaction in block `15479087` and the first transaction in block `15479088`. Report the average fees of these two transactions.

- Hint: Assume the first transaction in a block is listed as the last row on the last page under that block on etherscan.io. Likewise, the last transaction in a block is listed as the first row on the first page under that block on etherscan.io.

Exercise 4. Automatically explore 50 transactions in one block
---

Note: the following code may take a few minutes to complete, and sometimes may need additional tweaks due to the changed API or response structure of etherscan.io. 

```python
import os
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone

import requests

API_URL = "https://api.etherscan.io/v2/api"
API_KEY = "CHX8WJARQ571B9JFT3D5NFWERZGN7KQ9JN" # or request your own on https://etherscan.io/myapikey 
CHAIN_ID = 1          # 1 mainnet, 11155111 sepolia, 8453 base, 42161 arbitrum
WEI = 10**18

TX_TYPES = {0: "Legacy", 1: "Access List", 2: "Dynamic Fee", 3: "Blob", 4: "Set Code"}

# The free tier allows 5 requests/second. One shared throttle keeps the worker
# threads below that ceiling no matter how many of them are running.
_rate_lock = threading.Lock()
_next_call_at = 0.0


def _throttle(min_gap=0.5):
    global _next_call_at
    with _rate_lock:
        now = time.monotonic()
        wait = _next_call_at - now
        _next_call_at = max(now, _next_call_at) + min_gap
    if wait > 0:
        time.sleep(wait)


def _get(**params):
    """One call to Etherscan's proxy module, which mirrors Ethereum JSON-RPC."""
    params.update(chainid=CHAIN_ID, module="proxy", apikey=API_KEY)
    _throttle()
    response = requests.get(API_URL, params=params, timeout=30)
    response.raise_for_status()
    body = response.json()

    if "error" in body:
        raise RuntimeError(body["error"].get("message", body["error"]))
    # A bad key, an exhausted quota or an endpoint outside your plan arrives as
    # HTTP 200 with status "0", so it has to be checked separately.
    if str(body.get("status")) == "0":
        raise RuntimeError(body.get("result") or body.get("message"))
    return body.get("result")


def scrape_block(blocknumber, page=1, with_fees=True):
    """`page` is accepted so existing calls keep working, but it is ignored:
    one request returns every transaction in the block, so there is nothing
    left to paginate."""
    if not API_KEY:
        raise SystemExit(
            "Set ETHERSCAN_API_KEY first -- free key at https://etherscan.io/myapikey"
        )

    block = _get(action="eth_getBlockByNumber", tag=hex(blocknumber), boolean="true")
    if block is None:
        raise SystemExit(f"block {blocknumber} not found (beyond the chain head?)")

    txs = block["transactions"]
    block_timestamp = int(block["timestamp"], 16)

    # gasUsed lives on the receipt rather than the block, so the fee costs one
    # extra lookup per transaction. Four workers saturate the rate limit.
    receipts = [None] * len(txs)
    if with_fees and txs:
        with ThreadPoolExecutor(max_workers=4) as pool:
            receipts = list(
                pool.map(
                    lambda t: _get(action="eth_getTransactionReceipt", txhash=t["hash"]),
                    txs,
                )
            )

    rows = []
    for tx_json, receipt in zip(txs, receipts):
        tx = extract_transaction_info(tx_json, receipt, block_timestamp)
        rows.append(tx)
        print("transaction of ID:", tx['hash'], "block:", tx['block'],
              "from address", tx['from'], "toaddress", tx['to'],
              "transaction fee", tx['fee'])
    return rows


def extract_transaction_info(tx, receipt=None, block_timestamp=None):
    """Same return shape as before, built from JSON instead of table cells."""
    receipt = receipt or {}

    gas_used = int(receipt["gasUsed"], 16) if receipt.get("gasUsed") else None
    # effectiveGasPrice appears on EIP-1559 receipts; older ones fall back to
    # the price quoted on the transaction itself.
    raw_price = receipt.get("effectiveGasPrice") or tx.get("gasPrice")
    gas_price = int(raw_price, 16) if raw_price else None

    fee = f"{gas_used * gas_price / WEI:.8f}" if gas_used and gas_price else "n/a"

    to_address = tx.get("to")
    if to_address is None:                       # contract creation has no `to`
        created = receipt.get("contractAddress")
        to_address = f"[contract created] {created}" if created else "[contract created]"

    status = receipt.get("status")

    return {
        'hash': tx['hash'],
        'type': TX_TYPES.get(int(tx.get('type', '0x0'), 16), tx.get('type')),
        'block': int(tx['blockNumber'], 16),
        'timestamp': datetime.fromtimestamp(block_timestamp, timezone.utc)
                             .isoformat(timespec='seconds') if block_timestamp else None,
        'from': tx['from'],
        'to': to_address,
        'value': f"{int(tx['value'], 16) / WEI:.8f}",
        'fee': fee,
        'gas_price': f"{gas_price / 1e9:.4f} gwei" if gas_price else None,
        'status': {'0x1': 'success', '0x0': 'failed'}.get(status),
    }


if __name__ == "__main__":  # entrance to the main function
    scrape_block(15479087, 1)
```

In this exercise, you will run the Python code to crawl data from the etherscan website automatically. The example code above sends requests to the Etherscan Explorer (i.e., https://etherscan.io/txs?block=15479087) to read the last 50 transactions in block `15479087`.

To run the code, you will need a Python runtime and some libraries. If your computer does not support Python (yet), you can find installation instructions on
https://www.python.org/downloads/ for both Windows and Mac machines. In addition, the Python libraries can be installed in a Python console: 

```bash
>>> pip3 install requests
>>> pip3 install beautifulsoup4
```

After installation, copy the above python code to a file and run the file in a python runtime (e.g., your favorite python IDE). After running the code, you can observe transaction attributes printed on the terminal or Python console.

Exercise 5. Automatically explore all transactions in one block
---

In this exercise, you are required to report the average fee of all transactions in block `15479087`. You can modify the given code.

- Hint: transactions in block `15479087` are listed on three pages.

Exercise 6. Automatically explore transactions across two blocks
---

In this exercise, you are required to report the average fees of 100 transactions, which are the first 50 transactions in block `15479087` and the first 50 transactions in block `15479088`. You need to modify the given code.

Exercise 7 (Additional). Automatically explore contract-calling transactions in one block
---

In this exercise, you are required to report the number of transactions in block `15479087` that call the method `Approve`. You can modify the given code.

Deliverable
---

1. Report the transaction fee required for each exercise.
2. For exercise 4, submit the screenshot that runs the crawler code on your computer.
    - If there are too many results that cannot fit into a single screen, you can randomly choose two screens and do two screenshots. 
3. For exercise 5/6/7, submit your modified Python file and the screenshot that runs the code on your computer. The Python programs need to be stored in plaintext format and in separate files from your report. 

FAQ
---

- Question: How to verify your code is correct?
    - Answer: Let's say your modified Python code needs to scan 100 transactions and calculate the average transaction fee. To verify your code is correct, you can change the number 100 in your program to a smaller one, say 3, and manually calculate the average fee of the 3 transactions. If the manual calculation result equals your program result, it shows that your program is likely to be correct.
- Question: Can I do lab exercises 4/5/6 without installing anything on my computer?
    - Answer: Yes, it is possible. You could use Google's colab platform that supports running python code in a web browser:  https://colab.research.google.com/?utm_source=scs-index .
- Question: How to install a Python IDE?
    - Answer: It is not required to install a Python IDE (Python runtime is enough). But if you want, you can install the Pycharm for Python IDE (the community version) by following the instruction here: https://www.jetbrains.com/help/pycharm/installation-guide.html#toolbox. You will need to configure Python interpreter in Pycharm: https://www.jetbrains.com/help/pycharm/configuring-local-python-interpreters.html.

