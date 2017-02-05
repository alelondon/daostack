async function  genesisInit() {
    // create a value system
    var founders = [accounts[0],accounts[1],accounts[2]];
    var tokenForFounders = [1,2,4];
    var repForFounders = [7,9,12];

    let votingScheme = await SimpleVote.new();

    let genesis = await GenesisScheme.new("Shoes factory",
                                          "SHOE",
                                          founders,
                                          tokenForFounders,
                                          repForFounders,
                                          votingScheme.address,
                                          {'start_gas':4700000} );

    var controllerAddress = await genesis.controller();
    var controllerInstance = Controller.at(controllerAddress);

    var reputationAddress = await controllerInstance.nativeReputation();
    var reputationInstance = Reputation.at(reputationAddress);

    var tokenAddress = await controllerInstance.nativeToken();
    var tokenInstance = MintableToken.at(tokenAddress);

    var i;
    for (i = 0 ; i < founders.length ; i++ ) {
       await genesis.collectFoundersShare({'from': founders[i]});
    }


// For struct instal js-struct: npm install js-struct

    const newValueSystem = Struct([
      Type.GenesisScheme('genesis'),
      Type.Controller('controllerInstance'),
      Type.Reputation('reputationInstance'),
      Type.MintableToken('tokenInstance')
    ]);

    return newValueSystem
}
