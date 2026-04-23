import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const creditScore = await deploy("PrivateCreditScore", {
    from: deployer,
    log: true,
  });
  console.log("PrivateCreditScore deployed at:", creditScore.address);

  const payroll = await deploy("ConfidentialPayroll", {
    from: deployer,
    log: true,
  });
  console.log("ConfidentialPayroll deployed at:", payroll.address);

  const portfolio = await deploy("HiddenPortfolio", {
    from: deployer,
    log: true,
  });
  console.log("HiddenPortfolio deployed at:", portfolio.address);
};

export default func;
func.tags = ["PrivaFi"];
