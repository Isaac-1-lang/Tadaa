// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Tracker {
    enum Stage { Manufactured, ShippedByManufacturer, ReceivedByDistributor, ShippedByDistributor, ReceivedByRetailer, Purchased }
    
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
        address distributor;
        address retailer;
        address customer;
        Stage stage;
        uint256 timestamp;
    }
    
    mapping(uint256 => Product) public products;
    uint256 public productCount;
    
    event ProductCreated(uint256 id, string name, address manufacturer);
    event ProductShipped(uint256 id, Stage stage, address from);
    event ProductReceived(uint256 id, Stage stage, address to);
    event ProductPurchased(uint256 id, address customer);
    
    modifier onlyManufacturer(uint256 _id) {
        require(products[_id].manufacturer == msg.sender, "Only manufacturer can perform this action");
        _;
    }
    
    modifier onlyDistributor(uint256 _id) {
        require(products[_id].distributor == msg.sender, "Only distributor can perform this action");
        _;
    }
    
    modifier onlyRetailer(uint256 _id) {
        require(products[_id].retailer == msg.sender, "Only retailer can perform this action");
        _;
    }
    
    function createProduct(string memory _name) public returns (uint256) {
        productCount++;
        products[productCount] = Product({
            id: productCount,
            name: _name,
            manufacturer: msg.sender,
            distributor: address(0),
            retailer: address(0),
            customer: address(0),
            stage: Stage.Manufactured,
            timestamp: block.timestamp
        });
        
        emit ProductCreated(productCount, _name, msg.sender);
        return productCount;
    }
    
    function shipToDistributor(uint256 _id, address _distributor) public onlyManufacturer(_id) {
        require(products[_id].stage == Stage.Manufactured, "Product already shipped");
        products[_id].distributor = _distributor;
        products[_id].stage = Stage.ShippedByManufacturer;
        products[_id].timestamp = block.timestamp;
        
        emit ProductShipped(_id, Stage.ShippedByManufacturer, msg.sender);
    }
    
    function receiveByDistributor(uint256 _id) public onlyDistributor(_id) {
        require(products[_id].stage == Stage.ShippedByManufacturer, "Product not shipped by manufacturer");
        products[_id].stage = Stage.ReceivedByDistributor;
        products[_id].timestamp = block.timestamp;
        
        emit ProductReceived(_id, Stage.ReceivedByDistributor, msg.sender);
    }
    
    function shipToRetailer(uint256 _id, address _retailer) public onlyDistributor(_id) {
        require(products[_id].stage == Stage.ReceivedByDistributor, "Product not received by distributor");
        products[_id].retailer = _retailer;
        products[_id].stage = Stage.ShippedByDistributor;
        products[_id].timestamp = block.timestamp;
        
        emit ProductShipped(_id, Stage.ShippedByDistributor, msg.sender);
    }
    
    function receiveByRetailer(uint256 _id) public onlyRetailer(_id) {
        require(products[_id].stage == Stage.ShippedByDistributor, "Product not shipped by distributor");
        products[_id].stage = Stage.ReceivedByRetailer;
        products[_id].timestamp = block.timestamp;
        
        emit ProductReceived(_id, Stage.ReceivedByRetailer, msg.sender);
    }
    
    function purchaseProduct(uint256 _id) public {
        require(products[_id].stage == Stage.ReceivedByRetailer, "Product not available for purchase");
        products[_id].customer = msg.sender;
        products[_id].stage = Stage.Purchased;
        products[_id].timestamp = block.timestamp;
        
        emit ProductPurchased(_id, msg.sender);
    }
    
    function getProduct(uint256 _id) public view returns (
        uint256 id,
        string memory name,
        address manufacturer,
        address distributor,
        address retailer,
        address customer,
        Stage stage,
        uint256 timestamp
    ) {
        Product memory p = products[_id];
        return (p.id, p.name, p.manufacturer, p.distributor, p.retailer, p.customer, p.stage, p.timestamp);
    }
}
