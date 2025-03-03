// verify.js
const { exec } = require("child_process");

// Read dynamic data from environment variables or process.argv
const network = "abstractTestnet"; // the network you want to deploy to either abstractabstractMainnet or abstractTestnet
const contractAddress =  "0x6cB6BB497C7821339aFC3aD316a4193A35141FD2"; // the address of the contract you want verify
const arg1 = "0x80053651DEd8bCB962b6fdA539D4772306DBd41C"; // the address of the owner of the contract
const arg2 = "0x58a375108E88B3eb915F89E297891432199eE3D9"; // the address of the owner of the contract
const arg3 = "ipfs://bafybeicris4xdmwetj4p2gqvibtqay2xiet5tkf4jkruyuvxxjl5lf5bvi"; // the baseURI of the contract

const command = `npx hardhat verify --network ${network} ${contractAddress} ${arg1} ${arg2} ${arg3} --contract contracts/Army721.sol:Army`;

console.log("Running command:", command);
exec(command, (err, stdout, stderr) => {
  if (err) {
    console.error("Error:", err);
    return;
  }
  console.log(stdout);
  console.error(stderr);
});
