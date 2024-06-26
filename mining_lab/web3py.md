To efficiently retrieve the information stored in your Ethereum node, such as blocks and transactions, you can use Python to work with the Web3py library. 

1. Open a new terminal and install python3 
```bash
   sudo apt updates
   sudo apt upgrades
   sudo apt install python3.6
```
2. Install web3
```bash
   sudo python3.6 -m pip install web3
```

3. Write your own python code (say __get_bkc.py__) to retrieve content from your Ethereum node. 
```
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

for i in range(1, 10):
    print(w3.eth.getBlock(i))
    # or
    print(w3.eth.get_block(i)) 
```

4. Execute the above code will print out the first 10 blocks.
```
python3.6 get_bkc.py
```
__Note: if executing the above code throws the connection error, that means your geth did not enable the RPC. You can enable RPC by add '--rpc' (or --http) when you start geth in  the last command of step 2.1. See the following example.__
```
'geth --datadir bkc_data --http --allow-insecure-unlock --networkid 89992018 console 2>console.log'.
``` 

More web3py functions for working with Ethereum can be found at https://web3py.readthedocs.io/en/stable/web3.eth.html.
