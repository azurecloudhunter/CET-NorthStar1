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

# North Star Architecture

The principal challenges facing enterprise customers adopting Azure are 1) how to allow applications (legacy or modern) to seamlessly move at their own pace, and 2) how to provide secure and streamlined operations, management, and governance across the entire platform and all encompassed applications. To address these challenges, customers require a forward looking and Azure-native design approach, which in the context of this playbook is represented by the "North Star" architecture.

## What is the North Star Architecture?

The "North Star" architecture represents the strategic design path and target technical state for the customer's Azure environment. It will continue to evolve in lockstep with the Azure platform and is ultimately defined by the various design decisions the customer organization must make to define their Azure journey.

It is important to highlight that not all enterprises adopt Azure in the same way, and as a result the "North Star" architecture may vary between customers. Ultimately, the technical considerations and design recommendations presented within this playbook may yield different trade-offs based on the customer scenario. Some variation is therefore expected, but provided core recommendations are followed, the resultant target architecture will position the customer on a path to sustainable scale.

## Landing Zone Definition

Within the context of the "North Star" architecture, a "Landing Zone" is a logical construct capturing everything that must be true to enable application migrations and greenfield development at an enterprise scale in Azure. It considers all platform resources that are required to support the customer's application portfolio and does not differentiate between IaaS or PaaS.

Every large enterprise software estate will encompass a myriad of application archetypes and each "Landing Zone" essentially represents the common elements, such as networking and IAM, that are shared across instances of these archetypes and must be in place to ensure that migrating applications have access to requisite components when deployed. Each "Landing Zones" must consequently be designed and deployed in accordance with the requirements of archetypes within the customer's application portfolio.

The principle purpose of the "Landing Zone" is therefore to ensure that when an application lands on Azure, the required "plumbing" is already in place, providing greater agility and compliance with enterprise security and governance requirements.

---
_Using an analogy, this is similar to how city utilities such as water, gas, and electricity are accessible before new houses are constructed. In this context, the network, IAM, policies, management, and monitoring are shared 'utility' services that must be readily available to help streamline the application migration process._
***

[![Landing Zone](./media/lz-design.png "Landing Zone")](#)

Figure 1 – "Landing Zone" Design

The following list expands on the "Landing Zone" illustration by iterating through the core technical constructs which must be designed and developed within the context of customer requirements to create compliant technical "Landing Zone" environments and the conditions for successful Azure adoption.

-   ***Identity and Access Management***: Azure AD design and integration must be built to ensure both server and user authentication. RBAC must be modelled and deployed to enforce separation of duties and the required entitlements for platform operation and management. Key management must be designed and deployed to ensure secure access to resources and support operations such as rotation and recovery. Ultimately, access roles are assigned to application owners at the control and data planes to create and manage resources autonomously.

-   ***Policy Management*** Holistic and "Landing Zone" specific policies must be identified, described, built and deployed onto the target Azure platform to ensure corporate, regulatory and line of business controls are in place. Ultimately, policies should be used to guarantee the compliance of applications and underlying resources without any abstraction provisioning/administration capability.

-   ***Management and Monitoring***: Platform level holistic (horizontal) resource monitoring and alerting must be designed, deployed, and integrated. Operational tasks such as patching and backup must also be defined and streamlined. Security operations, monitoring, and logging must be designed and integrated with both resources on Azure as well as existing on-premises systems. All Subscription activity logs , which capture control plane operations across resources, should be streamed into Log Analytics to make them available for query and analysis, subject to RBAC permissions.

-   ***Network Topology and Connectivity***: The end-to-end network topology must be built and deployed across Azure regions and on-premises customer environments to ensure North-South and East-West connectivity between platform deployments. Network security must also be designed with the required services and resources identified, deployed and configured, such as Firewalls and NVAs to ensure security requirements are fully met.

-   ***Shared Services Infrastructure***: Centrally controlled but de-centrally deployed services, such as Domain Controllers, must be designed, configured, and built to make requisite common services and resources available for application teams to consume and integrate with. It is important to note that not all "traditional" on premise shared services should be provided in the cloud. For example, file shares and HSMs should be considered as application level resources using native-Azure services.

-   ***DevOps***: An end-to-end DevOps experience with robust SDLC practices must be designed, built and deployed to ensure the safe, repeatable and consistent delivery of Infrastructure as Code artifacts. Such artifacts are to be developed, tested and deployed using dedicated integration, release and deployment pipelines with strong source control and traceability.

In addition to the key aspects denoted above, the design, configuration, deployment, and integration of each "Landing Zone" should meet critical customer requirements relating to:

-   Business Continuity and Disaster Recovery, both at the platform and application level.
-   Service Management, such as incident response and support.
-   Service Catalogue, such as CMDB.

## High Level Architecture
[![North Star Architecture](./media/ns-arch.png "North Star Architecture")](#)

Figure 2 – "North Star" Architecture