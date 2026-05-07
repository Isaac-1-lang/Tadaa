const Tracker = artifacts.require("Tracker");

contract("Tracker", (accounts) => {
  const [manufacturer, distributor, retailer, customer] = accounts;
  let tracker;

  beforeEach(async () => {
    tracker = await Tracker.new();
  });

  it("should create a product", async () => {
    const result = await tracker.createProduct("Laptop", { from: manufacturer });
    const productCount = await tracker.productCount();
    
    assert.equal(productCount.toNumber(), 1, "Product count should be 1");
    
    const product = await tracker.getProduct(1);
    assert.equal(product.name, "Laptop", "Product name should be Laptop");
    assert.equal(product.manufacturer, manufacturer, "Manufacturer should match");
    assert.equal(product.stage.toNumber(), 0, "Stage should be Manufactured");
  });

  it("should track full supply chain lifecycle", async () => {
    // Manufacturer creates product
    await tracker.createProduct("Smartphone", { from: manufacturer });
    
    // Manufacturer ships to distributor
    await tracker.shipToDistributor(1, distributor, { from: manufacturer });
    let product = await tracker.getProduct(1);
    assert.equal(product.stage.toNumber(), 1, "Stage should be ShippedByManufacturer");
    
    // Distributor receives
    await tracker.receiveByDistributor(1, { from: distributor });
    product = await tracker.getProduct(1);
    assert.equal(product.stage.toNumber(), 2, "Stage should be ReceivedByDistributor");
    
    // Distributor ships to retailer
    await tracker.shipToRetailer(1, retailer, { from: distributor });
    product = await tracker.getProduct(1);
    assert.equal(product.stage.toNumber(), 3, "Stage should be ShippedByDistributor");
    
    // Retailer receives
    await tracker.receiveByRetailer(1, { from: retailer });
    product = await tracker.getProduct(1);
    assert.equal(product.stage.toNumber(), 4, "Stage should be ReceivedByRetailer");
    
    // Customer purchases
    await tracker.purchaseProduct(1, { from: customer });
    product = await tracker.getProduct(1);
    assert.equal(product.stage.toNumber(), 5, "Stage should be Purchased");
    assert.equal(product.customer, customer, "Customer should match");
  });

  it("should enforce manufacturer-only shipping", async () => {
    await tracker.createProduct("Tablet", { from: manufacturer });
    
    try {
      await tracker.shipToDistributor(1, distributor, { from: distributor });
      assert.fail("Should have thrown an error");
    } catch (error) {
      assert(error.message.includes("Only manufacturer can perform this action"));
    }
  });

  it("should prevent skipping stages", async () => {
    await tracker.createProduct("Monitor", { from: manufacturer });
    
    try {
      await tracker.receiveByDistributor(1, { from: distributor });
      assert.fail("Should have thrown an error");
    } catch (error) {
      assert(error.message.includes("Product not shipped by manufacturer"));
    }
  });
});
