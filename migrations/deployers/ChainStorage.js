const getConfig = require('../helpers/getConfig');

module.exports = (
  deployer,
  network,
  accounts,
  ChainStorageArtifact,
) => deployer.then(async () => {
  const { options, config } = getConfig(network, accounts);

  return deployer.deploy(
    ChainStorageArtifact,
    config.Chain.blocksPerPropose,
    config.Chain.blocksPerReveal,
    config.Chain.minimumStakingTokenPercentage,
    false,
    options,
  );
});
