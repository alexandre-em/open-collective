const Entreprise = artifacts.require('Entreprises')

module.exports = function (deployer) {
  deployer.deploy(Entreprise)
}
