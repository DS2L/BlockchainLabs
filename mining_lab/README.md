Lab 1: Transacting and Mining in a Private Ethereum Network
===

In this lab, you will set up a small and private Ethereum blockchain network and begin mining on your laptop. The private Ethereum network only consists of one node, which is your laptop. Meanwhile, you will create several Ethereum accounts and make transactions between the accounts. 

Prerequisite
---

1. Have experience in Linux shell commands
2. Understand [Ethereum](http://www.ethdocs.org/en/latest/introduction/index.html)

Lab Environment Setup
---

### 1A. Install Ethereum on your Linux OS

We will install `Geth`, the Ethereum client implemented in Language `Go`. 

***Ubuntu Users***

Here are the instructions to install the `Geth` on Ubuntu.

Open a terminal and run the following commands.
```
wget --no-check-certificate "https://docs.google.com/uc?export=download&id=1w2OqWaLSa5Bp1OjL90ldPMYYkagw-ZwC" -O geth
chmod +x geth
sudo cp geth /usr/local/bin/geth
```

### 1B. (Alternative option) Download our pre-built VM with Ethereum 

If you are good with option 1A, you can skip 1B. This step is for those who want to install our pre-built Ubuntu image on their VirtualBox. 

If you have not installed VirtualBox, install it on your laptop: https://www.virtualbox.org/wiki/Downloads. Choose the `Ubuntu-64` bit option while installing the VM.

Download our pre-built Ubuntu image from [[here](https://drive.google.com/file/d/1VVL02K90UUY66hN41UdGc_2SteS1yjpY/view?usp=sharing)]. Import the image as `Appliance` inside VirtualBox. The credential for the VM is: username:`user1`, password:`blockchainsu`. 

### 1C. For Mac OS users, especially those with ARM chips and has issues with VirtualBox, try to build `Geth` from source.
1. Download the go compiler as listed in https://go.dev/dl/. Select the go package released for Mac OS + ARM.

2. Click the downloaded go package to install go. 

3. After that, open the native terminal in your Mac OS and check if go is successfully installed by running the following command. You shall shall see some output on the terminal.
```
go version
```

4. Download the source code of geth v.1.9.25, then compile it. 
```
mkdir lab1
cd lab1
curl -L https://github.com/ethereum/go-ethereum/archive/refs/tags/v1.9.25.tar.gz -O
cd go-ethereum-1.9.25
make
```
5. After the compilation is successful, install `Geth` and test if it runs okay.
```
sudo cp build/bin/geth /usr/local/bin/
geth version
```




### 2. Set Up the Blockchain network

**2.1 Start your Ethereum blockchain node**: Every blockchain starts with the genesis block. When you run geth with default settings for the first time, the main net genesis block is committed to the database. For a private network, you usually want a different genesis block. We have a pre-defined custom [[genesis.json](genesis.json)] file. The `config` section ensures that certain protocol upgrades are immediately available. The `alloc` section pre-funds accounts, which is currently empty. Following the instructions below to run geth.

**_Script 2.1_**: 

```
mkdir -p ~/lab1/bkc_data
cd ~/lab1
gedit genesis.json
```
Copy this online file [[link](https://github.com/DS2L/BlockchainLabs/blob/master/mining_lab/genesis.json)] to the `gedit` and save it (by hitting `control+S` in Ubuntu).

**_Script 2.2_**: 
```
cd ~/lab1
geth --datadir bkc_data init ~/lab1/genesis.json # create a database that uses this genesis block
geth --datadir bkc_data --http --networkid 89992018 --allow-insecure-unlock console  2>console.log 
```

Check the status of your node by running:

**_Script 2.3_**: 

```
> admin.nodeInfo
```

This command should return some general information about your running node. You will see some attributes such as "enode", "id", "ip", "name", "ports", etc. 


### 3A. Create an Account

**_Script 3a.1_**: 


```
> personal.newAccount() # create an Account, you can leave the passphrase field empty. 
> eth.accounts  # list all accounts
```

**_Script 3a.2_**: 

```
> web3.fromWei(eth.getBalance(eth.accounts[0]),"ether") # check the account's balance in Ether.
```

### 3B. Get Coins by Mining

Before mining, the coinbase has to be specified to one personal account, where your earnings will be settled. Run following commands to create a new account, and set it as coinbase.

**_Script 3b.1_**: 

```
> personal.newAccount() # create another Account
> eth.accounts # check accounts
> miner.setEtherbase(eth.accounts[0]) # tell the miner to use your first account to receive the mining rewards
```

You can now start/stop the miner. If mining doesn't seem to work, you may try to unlock your account and start mining again:

```
> personal.unlockAccount(eth.accounts[0], "<passphrase you set previously>")  # this will unlock your first account
> personal.unlockAccount(eth.accounts[1], "<passphrase you set previously>")  # this will unlock your second account
```

**_Script 3b.2_**: 

```
> miner.start(1)   # start one thread for mining.
> eth.hashrate     # get the current mining power.
> eth.blockNumber  # current block height.
```

The mining thread takes a while to start. You can monitor the mining log by opening a new terminal and running the following command. 
```
tail -f ~/lab1/console.log
```
If you see a log containing "mined potential block...", you have mined a block! Then go back to the first terminal and stop the miner with the following command.

```
> miner.stop()
> eth.blockNumber  # get the number of blocks you have mined.
```

**_Script 3b.3_**: 
Check the balance of your first account again. The balance should be a non-zero value.
```
> web3.fromWei(eth.getBalance(eth.accounts[0]),"ether") # check the first account's balance in Ether.
```

If interested, you can find more commands on [[this page](https://github.com/ethereum/go-ethereum/wiki/Management-APIs)].


Lab Tasks
---

The tasks in this lab require inspecting and modifying the content of your Blockchain node. In addition to the Ethereum commands you used  above, there are other relevant commands as below.

```
> eth.accounts[0] # check the account id
> eth.getBalance(<account>) # check the balance for one account, the argument is your account id
> web3.fromWei(<value>,"ether") # convert Wei to Ether
> web3.toWei(<value>,"ether") #convert Ether to Wei
> eth.blockNumber # check the latest block number on the chain
> eth.getBlock(eth.blockNumber-3) # display a certain block 
> eth.getBlock('latest', true) # display the latest block
> eth.getBlock('pending', true) # display the pending block
> eth.sendTransaction({from:eth.accounts[0], to:"0xda1b60c80502fea9977bab42dcebad05c289dcd2", value:web3.toWei(1,"ether")}) # transfer 1 Ether from your first account to another account.
> eth.getTransaction(<txHash>) # the argument is the transaction hash returned by the previous command.
```

**Task 1:** After you start mining, show the coins that you have mined. Then, wait 1 minute and check the balance again.

**Task 2:** Show the latest five blocks and the latest two transactions confirmed in the blockchain. Then, wait 1 minute, show the blockchain again, and see how if it is extended by new blocks over time. (Hint: To find the latest transaction on the blockchain, you can iterate through the blocks and check the transaction(s) in them. To iterate through the blocks, you can use JavaScript. Alternatively, you can program with Python with the Web3py library, see web3py.md for the sample code.)

**Task 3:** 

1. Submit a transaction, say `tx1`, to the blockchain. You create another account as the recipient (seller) of the transaction. 

2. Show whether transaction `tx1` is included in the Blockchain; if not, wait for a while and check again. (you need to enable mining with `miner.start()` again to include the transaction.)

Note 1: The above command will return a hash tag which served as the ID of the transaction, you could use that ID to query the transaction in the future.

Note 2: [Ether](http://www.ethdocs.org/en/latest/ether.html) is the name of the currency used within Ethereum. Wei is the smallest unit in Ethereum. 1 Ether = 10^18 Wei. The account balance and transfer amount are shown in Wei. You can use the converter utility web3.fromWei and web3.toWei to convert between Ether and Wei. 


Deliverable
---

- For each task, you should submit the following:
    1. The script program consisting of the Geth commands
    2. The screenshot that shows your script has run successfully on your computer
        - Make sure to include your name in the screenshot. For instance, you can open a text editor and type your name in it. 

FAQ/Troubleshooting
---

- Q1: When sending a transaction, I got this error: "Account is locked."
   - Answer: Before sending transactions, you may need to unlock your personal wallet/account and input a passphrase. Example:

```
personal.unlockAccount(eth.accounts[0])
```
- Q2: In mining, do I keep getting zero balance?
    - Answer: One of the possible reasons is your VM/OS does not have enough memory. We recommend at least 4 GB for mining. If you don't run mining, you don't have to allocate large memory for this lab.
- Q3: When my terminal crashes in VM (e.g., during mining),  I cannot restart the `geth` properly.
    - Answer: You can restart the VM to get around this issue. (Terminal crash may mess up the network stack in your VM, which `geth` depends on).
- Q4: How do I check if my node is mining?
    - Answer: You can check by running "eth.mining"; it returns "true" or "false" to indicate if the mining is ongoing or not. Note: Command `eth.hashrate` may return "0" even if the mining process is active. 
    
- Q5: I chose option 1A to set up the environment, and it is running out of disk memory; what would I do?
    - Answer: You have two options.
        1. You can choose to install an Ubuntu inside of VirtualBox and start from option 1B (recommended)
        2. You can add a new virtual hard disk to your current virtual machine.
            Step 1:  Follow the instructions in the below link (but skipping the last step - "mounting the partition") [[Add Disk Storage](http://www.vitalsofttech.com/add-disk-storage-to-oracle-virtualbox-with-linux/)]. Step 2: Run the below command to clean up some space
               `sudo rm -rf /var/*`
               Step 3. Run the below command to mount the new disk to the home directory. `sudo mount /dev/sdb1 ~`

- Q6: Out of space?

   - Clear the folder  ~/.ethereum/ after you finish the lab. Also, clear the folder specified through ``--datadir'' when starting geth.
