// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  console.log("Iniciando deploy dos contratos...");

  // Definindo o supply inicial (1 milhão de tokens com 18 casas decimais)
  const initialSupply = hre.ethers.parseUnits("1000000", 18);

  // Deploy do contrato EnerZ
  const EnerZ = await hre.ethers.getContractFactory("EnerZ");
  const enerZ = await EnerZ.deploy(initialSupply);
  await enerZ.waitForDeployment();
  console.log("EnerZ deployed para:", await enerZ.getAddress());

  // Deploy do contrato Groth16Verifier
  const Groth16Verifier = await hre.ethers.getContractFactory("Groth16Verifier");
  const verifier = await Groth16Verifier.deploy();
  await verifier.waitForDeployment();
  console.log("Groth16Verifier deployed para:", await verifier.getAddress());

  // Deploy do contrato Exchange
  const Exchange = await hre.ethers.getContractFactory("Exchange");
  const exchange = await Exchange.deploy(await enerZ.getAddress(), await enerZ.getAddress(), await verifier.getAddress());
  await exchange.waitForDeployment();
  console.log("Exchange deployed para:", await exchange.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
