# Supply Chain Tracker

A simple supply chain tracking smart contract built with Truffle and Solidity to track products from manufacturer to customer.

## What You'll Learn

- Writing Solidity smart contracts
- Using Truffle for compilation and deployment
- Testing smart contracts with Truffle
- Interacting with contracts using Ganache
- Understanding blockchain state management
- Working with events and modifiers

## Setup

1. **Install dependencies** (if not already done):
   ```bash
   npm install -g truffle ganache
   ```

2. **Start Ganache**:
   - Open Ganache GUI application, or
   - Run in terminal: `ganache --port 8545`

3. **Compile the contract**:
   ```bash
   truffle compile
   ```

4. **Deploy to Ganache**:
   ```bash
   truffle migrate
   ```

5. **Run tests**:
   ```bash
   truffle test
   ```

## How It Works

### Supply Chain Stages

1. **Manufactured** - Product created by manufacturer
2. **ShippedByManufacturer** - Sent to distributor
3. **ReceivedByDistributor** - Distributor confirms receipt
4. **ShippedByDistributor** - Sent to retailer
5. **ReceivedByRetailer** - Retailer confirms receipt
6. **Purchased** - Customer buys the product

### Key Features

- **Access Control**: Only authorized parties can perform specific actions
- **Stage Validation**: Products must follow the correct sequence
- **Transparency**: All transactions are recorded on the blockchain
- **Event Logging**: Important actions emit events for tracking

## Interacting with the Contract

### Using Truffle Console

```bash
truffle console
```

Then try these commands:

```javascript
// Get the deployed contract
let tracker = await Tracker.deployed()

// Get accounts
let accounts = await web3.eth.getAccounts()
let [manufacturer, distributor, retailer, customer] = accounts

// Create a product
await tracker.createProduct("Laptop", { from: manufacturer })

// Check product count
let count = await tracker.productCount()
console.log(count.toString())

// Get product details
let product = await tracker.getProduct(1)
console.log(product)

// Ship to distributor
await tracker.shipToDistributor(1, distributor, { from: manufacturer })

// Distributor receives
await tracker.receiveByDistributor(1, { from: distributor })

// Ship to retailer
await tracker.shipToRetailer(1, retailer, { from: distributor })

// Retailer receives
await tracker.receiveByRetailer(1, { from: retailer })

// Customer purchases
await tracker.purchaseProduct(1, { from: customer })

// Check final state
product = await tracker.getProduct(1)
console.log(product)
```

## Next Steps to Practice

1. **Add more features**:
   - Add product price and payment handling
   - Include product descriptions and metadata
   - Add batch tracking for multiple items

2. **Enhance security**:
   - Add role-based access control
   - Implement pausable functionality
   - Add product verification mechanisms

3. **Improve tracking**:
   - Store location data at each stage
   - Add quality check records
   - Track temperature/conditions for sensitive goods

4. **Build a frontend**:
   - Use Web3.js or Ethers.js
   - Create a React/Vue interface
   - Display product journey visually

## Troubleshooting

- **Port conflicts**: Change port in `truffle-config.js` if Ganache uses different port
- **Compilation errors**: Ensure Solidity version matches in contract and config
- **Migration issues**: Try `truffle migrate --reset` to redeploy from scratch
- **Test failures**: Make sure Ganache is running before running tests
- **Connection errors**: Ensure Ganache is running on port 8545 (or update truffle-config.js)

## Resources

- [Truffle Documentation](https://trufflesuite.com/docs/truffle/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ganache Documentation](https://trufflesuite.com/docs/ganache/)
