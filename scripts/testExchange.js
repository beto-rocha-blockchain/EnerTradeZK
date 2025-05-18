const hre = require("hardhat");

async function main() {
  const [deployer, buyer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with:", deployer.address);

  // Deploy mock payment token (e.g., DAI)
  const PaymentToken = await hre.ethers.getContractFactory("EnerZ");
  const paymentToken = await PaymentToken.deploy(hre.ethers.parseEther("10000"));
  await paymentToken.waitForDeployment();
  console.log("Mock PaymentToken deployed to:", paymentToken.target);

  // Deploy EnerZ token
  const EnerZ = await hre.ethers.getContractFactory("EnerZ");
  const enerZ = await EnerZ.deploy(hre.ethers.parseEther("10000"));
  await enerZ.waitForDeployment();
  console.log("EnerZ deployed to:", enerZ.target);

  // Deploy mock verifier
  const Groth16Verifier = await hre.ethers.getContractFactory("Groth16Verifier");
  const verifier = await Groth16Verifier.deploy();
  await verifier.waitForDeployment();
  console.log("Groth16Verifier deployed to:", verifier.target);

  // Deploy Exchange
  const Exchange = await hre.ethers.getContractFactory("Exchange");
  const exchange = await Exchange.deploy(
    enerZ.target,
    paymentToken.target,
    verifier.target
  );
  await exchange.waitForDeployment();
  console.log("Exchange deployed to:", exchange.target);

  // Transfer some paymentToken to buyer
  await paymentToken.transfer(buyer.address, hre.ethers.parseEther("1000"));
  console.log("Buyer recebeu 1000 tokens de pagamento");

  // Approve + deposit EnerZ
  await enerZ.approve(exchange.target, hre.ethers.parseEther("1000"));
  await exchange.deposit(hre.ethers.parseEther("500"));
  console.log("Deposited 500 EnerZ tokens to Exchange");

  // Create listing
  await enerZ.approve(exchange.target, hre.ethers.parseEther("100"));
  const tx = await exchange.createListing(
    hre.ethers.parseEther("100"),
    hre.ethers.parseEther("50") // price in paymentToken
  );
  await tx.wait();
  console.log("Listing criado com 100 ENZ por 50 tokens de pagamento");

  // Buyer aprova Exchange para gastar tokens de pagamento
  const buyerExchange = exchange.connect(buyer);
  const buyerPaymentToken = paymentToken.connect(buyer);
  await buyerPaymentToken.approve(exchange.target, hre.ethers.parseEther("50"));

  // Buyer compra o listing
  const txBuy = await buyerExchange.buyListing(1);
  await txBuy.wait();
  console.log("Buyer comprou o listing 1");

  // Checar saldo do comprador
  const buyerBalance = await enerZ.balanceOf(buyer.address);
  console.log("Buyer balance ENZ:", hre.ethers.formatEther(buyerBalance));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
