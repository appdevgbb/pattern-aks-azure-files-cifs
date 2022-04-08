/* Naming convention requirements */
param prefix string = 'gbb'
param location string = 'eastus'

/* Network Settings */
param vnetAddressPrefixes string = '10.0.0.0/16'

param aksSubnetInfo object = {
  name: 'AksSubnet'
  properties: {
    addressPrefix: '10.0.4.0/22'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${prefix}-${location}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixes
      ]
    }
    subnets: [
      aksSubnetInfo
    ]
  }
}

module aks 'modules/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    prefix: prefix
    subnetId: '${vnet.id}/subnets/${aksSubnetInfo.name}'
  }

}

/* Outputs */
output aksName string = aks.outputs.name
