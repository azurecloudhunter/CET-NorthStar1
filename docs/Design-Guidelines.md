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

# Design Guidelines
At the centre of the "North Star" architecture lies a critical design path, comprised of fundamental design topics with heavily interrelated and dependent design decisions. This repository provides design guidance across these architecturally significant technical domains to support the critical design decisions which must occur to define the "North Star" architecture. For each of the considered domains, readers should review provided considerations and recommendations, using them to structure and drive designs within each area.

## Critical Design Areas
The following eight critical design areas are intended to support the translation of customer requirements to Azure constructs and capabilities, to address the mismatch between on-premises infrastructure and cloud-design which typically creates dissonance and friction with respect to the "North Star" definition and Azure adoption. 

The impact of decisions made within these critical areas will reverberate across the "North Star" architecture and influence other decisions. Readers are strongly advised to familiarize themselves with these eight areas, to better understand the consequences of encompassed decisions, which may later produce trade-offs within related areas.

* [A - Enterprise Enrollment and Azure AD Tenants](./A-Enterprise-Enrollment-and-Azure-AD-Tenants.md)
* [B - Identity and Access Management](./B-Identity-and-Access-Management.md)
* [C - Management Group and Subscription Organization](./C-Management-Group-and-Subscription-Organization.md)
* [D - Network Topology and Connectivity](./D-Network-Topology-and-Connectivity.md)
* [E - Management and Monitoring](./E-Management-and-Monitoring.md)
* [F - Business Continuity and Disaster Recovery](./F-Business-Continuity-and-Disaster-Recovery.md)
* [G - Security, Governance and Compliance](./G-Security-Governance-and-Compliance.md)
* [H - Platform Automation and DevOps](./H-Platform-Automation-and-DevOps.md)
