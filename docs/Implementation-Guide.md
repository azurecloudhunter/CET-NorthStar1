## Navigation Menu

* [Overview](../README.md)
* [North Star Architecture](./NorthStar-Architecture.md)
  * [Design Principles](./Design-Principles.md)
  * [Design Guidelines](./Design-Guidelines.md)
    * [A - Enterprise Enrollment and Azure AD Tenants](./A-Enterprise-Enrollment-and-Azure-AD-Tenants.md)
    * [B - Identity and Access Management](./B-Identity-and-Access-Management.md)
    * [C - Management Group and Subscription Organization](./C-Management-Group-and-Subscription-Organization.md)
    * [D - Network Topology and Connectivity](./D-Network-Topology-and-Connectivity.md)
    * [E - Management and Monitoring](./E-Management-and-Monitoring.md)
    * [F - Business Continuity and Disaster Recovery](./F-Business-Continuity-and-Disaster-Recovery.md)
    * [G - Security, Governance and Compliance](./G-Security-Governance-and-Compliance.md)
    * [H - Platform Automation and DevOps](./H-Platform-Automation-and-DevOps.md)
  * [Implementation Guide](./Implementation-Guide.md)
* [Contoso Reference](./Contoso/Readme.md)
  * [Scope and Design](./Contoso/Scope.md)
  * [Implementation](./Contoso/Design.md)
* [Using reference implementation in your own environment](./Deploy/Readme.md)
  * [Getting started](./Deploy/Getting-Started.md)
    * [Prerequisites](./Deploy/Prerequisites.md)
    * [Validate prerequisites](./Deploy/Validate-prereqs.md)
  * [Configure your own environment](./Deploy/Using-Reference-Implementation.md)
    * [Configure GitHub](./Deploy/Configure-run-initialization.md)
    * [Provision Platform](./Deploy/Deploy-platform-infra.md)
    * [Create Landing Zones](./Deploy/Deploy-lz.md)
    * [Trigger deployments locally](./Deploy/Trigger-local-deployment.md)
  * [North Star ARM template](./Deploy/NorthStar-schema.md)
  * [Known Issues](./Deploy/Known-Issues.md)    
* [How Do I Contribute?](./Northstar-Contribution.md)
* [FAQ](./Northstar-FAQ.md)
* [Roadmap](./Northstar-roadmap.md)

---

# Implementation Guideline

This section covers how to get started with the Enterprise Scale platform-native reference implementation and outline design objectives.

There are three categories of activities that must take place in order to implement the Enterprise Scale architecture:

1. **What-must-be-true** for a the Enterprise Scale
   * Encompasses activities that must be performed by the Azure and Azure AD administrators to establish an initial configuration; these are sequential by nature and primarily one-off activities.

2. **Enable a new region (_File->New->Region_)**
   * Set of activities that are required whenever there is a need to expand the Enterprise-Scale platform into a new Azure region. 

3. **Deploy a new Landing Zone (_File->New->Landing Zone_)**
   * These are reoccurring activities that are required to instantiate a "Landing Zone"

To operationalize at scale, it is paramount that these activities follow the principal of "Infrastructure-as-Code" and automated using deployment pipelines.

## 1. What-must-be-true for the Enterprise Scale

### EA Enrollment & Azure AD Tenants

1. Setup the EA Administrator and Notification Account.

2. Create Department(s) – Business Domains/Geo Based/Org.

3. Create an EA Account under a Department.

4. Setup Azure AD Connect for each Azure AD Tenant if identity is to be synchronized from on-premises.

5. Establish zero standing access to Azure resources and Just-in time access via Azure AD PIM.

### Management Group and Subscription

1. Create Management Group hierarchy following the recommonations in this [article](./C-Management-Group-and-Subscription-Organization.md#1.-Define-Management-Group-Hierarchy).

2. Define an Subscription provisioning criteria along with the responsibilities of a Subscription Owner.

3. Create "Management", "Connectivity" and "Identity" Subscriptions for platform management, global networking as well as connectivity and identity resources (such as AD domain controllers).

4. Setup a Git repository to host IaC and Service Principle(s) for use with a platform CI/CD pipeline.

5. Create custom role definitions and manage entitlements using Azure AD PIM for Subscription and Management Group scopes.

6. Assign the Azure Policies in the table below for the Landing Zones.

| Name                  | Description                                                                                   |
|-----------------------|-----------------------------------------------------------------------------------------------|
| [Deny-PublicEndpoints](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policySetDefinitions-Deny-PublicEndpoints.parameters.json)  | Denies the creation of services with public endpoints on all landing zones                    |
| [Deploy-VM-Backup](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-VM-Backup.parameters.json)      | Ensures that backup is configured and deployed to all VMs in the Landing Zones                |
| [Deploy-vNet](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-vNet.parameters.json)           | Ensures that all Landing Zones have a VNet deployed and that it is peered to the regonal vHub |

### Global Networking & Connectivity

1. Allocate an appropriate VNet CIDR range for each Azure region where VWAN VHubs and VNets will be deployed

2. If you decide to create the networking ressources via Azure Policies, assign the Policies listed in the table below to the "Connectivity" Subscription. By doing this Azure Policy will ensure the resource in the list below are created based on parameters provided.
   * Create Azure Virtual WAN Standard
   * Create a VWAN VHub for each region. Ensure at least one gateway (ExpressRoute and/or VPN) per VWAN VHub are deployed)
   * Secure VWAN VHubs by deploying Azure Firewall within each VWAN VHub
   * Create required Firewall Policies and assign them to secure VHubs
   * Ensure all connected VNets to a secure VHub are protected by Azure Firewall

3. Deploy and configure an Azure Private DNS zones

4. Provision ExpressRoute circuit(s) with Private Peering. Follow instructions as per [article](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-routing-portal-resource-manager#private)

5. Connect on-premises HQs/DCs to Azure VWAN VHub via ExpressRoute circuits

6. Protect VNet traffic across VHubs with NSGs

7. (Optional) Setup encryption over ExpressRoute Private Peering. Follow instructions as per [article](https://docs.microsoft.com/en-us/azure/virtual-wan/vpn-over-expressroute)

8. (Optional) Connect branches to Azure VWAN VHub via VPN. Follow instructions as per [article](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-site-to-site-portal)

9. (Optional) Configure ExpressRoute Global Reach for connecting on\-premises HQs/DCs when more than one on\-premises location is connected to Azure via ExpressRoute. Follow instructions as per [article](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-set-global-reach)

Detailed list of Azure Policies that have be used when implementing networking resources for an Enterprise-Scale deployment:
| Name                     | Description                                                                            |
|--------------------------|----------------------------------------------------------------------------------------|
| [Deploy-FirewallPolicy](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-FirewallPolicy.parameters.json)  | Creates a Firewall Policy |
| [Deploy-vHUB](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-vHUB.parameters.json)        | This Policy deploys a VHub, Azure Firewall, Gateways(VPN/ER) and configures default route on connected VNets to Azure Firewall|
| [Deploy-VWAN](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-vWAN.parameters.json)            | Deploys a virtual WAN                             |

### Security, Governance & Compliance

1. Define and apply a [Service Enablement Framework](./G-Security-Governance-and-Compliance.md#5-service-enablement-framework) to ensure Azure services meet enterprise security and governance requirements.

2. Create custom Azure RBAC role definitions

3. Enable Azure AD PIM and discover Azure resources to facilitate privileged identity management

4. Create Azure AD only groups for the Azure control plane management of resources using Azure AD PIM

5. Apply Azure Policy listed in the first table below to ensure Azure services are compliant to enterprise requirements

6. Define a naming convention and enforce it via Azure Policy

7. Create a policy matrix at all scopes e.g. enable monitoring for all Azure services via Azure Policy

Detailed list of Azure Policies should be used to enforce company wide compliance status.

| Name                       | Description                                                        |
|----------------------------|--------------------------------------------------------------------|
| [Allowed-ResourceLocation](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Allowed-ResourceLocation.parameters.json)   | Specifies the allowed region where resourcen can be deployed       |
| [Allowed-RGLocation](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Allowed-RGLocation.parameters.json)         | Specifies the allowed region where resource groups can be deployed |
| [Denied-Resources](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Denied-Resources.parameters.json)           | Resource that are denied for the company                           |
| [Deny-AppGW-Without-WAF](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deny-AppGW-Without-WAF.parameters.json)     | Allows Application Gateways deployed with WAF enabled              |
| [Deny-IP-Forwarding](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deny-IP-Forwarding.parameters.json)         | Deny IP forwarding                                                 |
| [Deny-RDP-From-Internet](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deny-RDP-From-Internet.parameters.json)     | Deny RDP connections from internet                                 |
| [Deny-Subnet-Without-Nsg](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deny-Subnet-Without-Nsg.parameters.json)    | Deny Subnet creation without an NSG                                |
| [Deploy-ASC-CE](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-ASC-CE.parameters.json)              | Deploy ASC Continuous Export To Workspace                          |
| [Deploy-ASC-Monitoring](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-ASC-Monitoring.parameters.json)      | Enable Monitoring in Azure Security Center                         |
| [Deploy-ASC-Standard](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-ASC-Standard.parameters.json)        | Ensures that subscriptions have Security Centre Standard enabled.  |
| [Deploy-Diag-ActivityLog](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-Diag-ActivityLog.parameters.json)    | Enables Diagnostics Activitly Log and forwarding to LA             |
| [Deploy-Diag-LogAnalytics](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-Diag-LogAnalytics.parameters.json)   |                                                                    |
| [Deploy-VM-Monitoring](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-VM-Monitoring.parameters.json)       | Ensures that VM monitoring is enabled                              |

### Platform Indentity

1. If you decide to create the indentity ressources via Azure Policies, assign the Policies listed in the table below to the "Indentity" Subscription. By doing this Azure Policy will ensure the resource in the list below are created based on parameters provided.
   
2. Deploy the AD domain controllers

Detailed list of Azure Policies that can be used when implementing identity resources for an Enterprise-Scale deployment.

| Name                         | Description                                                               |
|------------------------------|---------------------------------------------------------------------------|
| [DataProtectionSecurityCenter](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-DataProtectionSecurityCenter.parameters.json) | ASC DataProtection, utomatically created by Azure Security Center         |
| [Deploy-vNet-Identity](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-vNet.parameters.json)         | Deploys a VNet into the idenity subscription to host for explample DC     |

### Platform Management and Monitoring

1. Create Policy Compliance and Security Dashboards for organizational and resource centric views

2. Create a workflow for platform secrets (service principles and automation account) and key rollover

3. Setup long-term archiving and retention for logs within Log Analytics

4. Setup Azure Key Vaults to store platform secrets

5. If you decide to create the platform management ressources via Azure Policies, assign the Policies listed in the table below to the "Management" Subscription. By doing this Azure Policy will ensure the resource in the list below are created based on parameters provided.

| Name                   | Description                                                                            |
|------------------------|----------------------------------------------------------------------------------------|
| [Deploy-LA-Config](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-LA-Config.parameters.json)       | Configuration of the Log Analytics workspace                                           |
| [Deploy-Log-Analytics](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-Log-Analytics.parameters.json)   | Deploys a Log Analytics Workspace |

## 2.  **File->New->Region**

1. If you decide to create the networking ressources via Azure Policies, assign the Policies listed in the table below to the "Connectivity" Subscription. By doing this Azure Policy will ensure the resource in the list below are created based on parameters provided.
   * Within the "Connectivity" subscription, create a new VHub within the existing Azure VWAN.
   * Secure VHub by deploying an Azure Firewall within the VHub and link existing or new Firewall Policies to Azure Firewall.
   * Ensure all connected VNets to a secure VHub are protected by Azure Firewall

2. Connect the VHub to on-premises using ExpressRoute or alternatively via VPN.

3. Protect VNet traffic across VHubs with NSGs.

4. (Optional) Setup encryption over ExpressRoute Private Peering.

| Name                     | Description                                                                            |
|--------------------------|----------------------------------------------------------------------------------------|
| [Deploy-vHUB](../../../tree/master/azopsreference/3fc1081d-6105-4e19-b60c-1ec1252cf560/contoso/.AzState/Microsoft.Authorization_policyDefinitions-Deploy-vHUB.parameters.json)        | This Policy deploys a VHub, Azure Firewall, Gateways(VPN/ER) and configures default route on connected VNets to Azure Firewall|

## 3. File->New->"Landing Zone" for applications and workloads

1. Create a Subscription and move it under the "Landing Zones" Management Group scope

2. Create Azure AD groups for the Subscription (N) – Owner, Reader, Contributor etc.

3. Create Azure AD PIM entitlements for established Azure AD groups.
