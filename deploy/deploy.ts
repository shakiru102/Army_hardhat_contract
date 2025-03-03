import { Wallet } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { vars } from "hardhat/config";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script`);

  // Initialize the wallet using your private key.
  const wallet = new Wallet(vars.get("DEPLOYER_PRIVATE_KEY"));

  // Create deployer object and load the artifact of the contract we want to deploy.
  const deployer = new Deployer(hre, wallet);
  // Load contract
  const artifact = await deployer.loadArtifact("Army");

  // Deploy this contract. The returned object will be of a `Contract` type,
  // similar to the ones in `ethers`.
  const tokenContract = await deployer.deploy(artifact, ["0x80053651DEd8bCB962b6fdA539D4772306DBd41C", "0x58a375108E88B3eb915F89E297891432199eE3D9" ,"ipfs://bafybeicris4xdmwetj4p2gqvibtqay2xiet5tkf4jkruyuvxxjl5lf5bvi"]);

  console.log(
    `${
      artifact.contractName
    } was deployed to ${await tokenContract.getAddress()}`
  );
}
