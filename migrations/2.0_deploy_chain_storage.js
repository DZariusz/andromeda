const getConfig = require('./helpers/getConfig');

const ChainStorageArtifact = artifacts.require('ChainStorage');

module.exports = (deployer, network, accounts) => {
  const { options, config } = getConfig(network, accounts);

  return deployer.deploy(
    ChainStorageArtifact,
    config.Chain.blocksPerPropose,
    config.Chain.blocksPerReveal,
    config.Chain.minimumStakingTokenPercentage,
    false,
    options,
  );
};
