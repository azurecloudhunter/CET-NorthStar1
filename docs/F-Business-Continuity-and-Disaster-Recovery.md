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

# F. Business Continuity and Disaster Recovery
Organizations need a Business Continuity and Disaster Recovery strategy that determines how applications and data remain available during planned and unplanned downtime. 

Your tolerance for reduced functionality during a disaster is a business decision that varies from one application to the next. It might be acceptable for some applications to be unavailable or to be partially available with reduced functionality or delayed processing for a period of time. For other applications, any reduced functionality is unacceptable.

### 1. Planning for BCDR

Know your business requirements. As you strive for more uptime nines so does your cost increase. Read [this article](https://docs.microsoft.com/en-us/azure/architecture/framework/resiliency/business-metrics) to define your own target SLA and recovery metrics (RTO/RPO).

***Design Considerations***

-   Define Application and data availability requirements
    -   Use of active-active and/or active-passive availability patterns that can meet workload RTO and RPO requirements in Azure.
    
    -   Define the application ability to gracefully handle and recover from both transient and permanent faults. Use [common patterns](https://docs.microsoft.com/en-us/azure/architecture/patterns/category/resiliency) 

    -   Support for multi-region deployments for failover purposes.

    -   Investigate application component proximity requirements for performance/latency reasons.

    -   Application operations with reduced functionality or degraded performance in the presence of an outage.

-   Investigate Workload suitability for [Availability Zones](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview)

    -   For Availability Zone SLA of 99.99% to apply, you need to spread your workload across ***at least TWO zones*** in the same region.

    -   Impact of Availability Zones on update domains compared to Availability Sets; percentage of workload that can be simultaneously under maintenance.

    -   Consider Inter zone latency requirements. Depending on region data center layout you may see network latency differences between zones. The difference is for most applications negligible - but in certain scenarios, like with extremely chatty applications, sub millisecond differences can have an undesirable effect on end users.

    -   Data replication costs between availability zones.

    -   Investigate VM SKUs required for the workload are available in the desired Availability Zones. Availability of specialized SKUs with GPU and HPC may vary across the zones in a region.

    -   If you intend to us Ultra-Disks, usage of Availability Zones is mandatory.

-   Ensure consistent backups and replication of data for applications in case of catastrophic loss.
    
    -   The frequency of running the backup process determines your RPO. For example, if you perform hourly backups and a disaster occurs two minutes before the backup, you will lose 58 minutes of data. Your disaster recovery plan should include how you will address lost data.

    -   VM snapshots is a read-only copy of a virtual hard drive (VHD). If you are going to use snapshots for recreating VM's you need to ensure consistency by cleanly shut down the VM first.

    -   Consider Subscription limits restricting the number of Recovery Service Vaults and the size of each vault.

    -   PaaS services may or may not support Geo-replication and HA capabilities. Consider disaster recovery capabilities for each individual PaaS service included in the solution.

-   ExpressRoute is designed for high availability to provide carrier grade private network connectivity to Microsoft resources.

    -   Bandwidth capacity planning for ExpressRoute is important even though it's easy to upgrade circuits from a platform perspective, consider checking capacity with your connectivity provider.
      
    -   Consider traffic routing effects in the case of a region/zone/network outage.

-   Operational readiness testing for the workload

    -   Perform an operational readiness test for failover to the secondary region and for fallback to the primary region. Many Azure services support manual failover or test failover for disaster recovery drills. Alternatively, you can simulate an outage by shutting down or removing Azure services.  

    -   Consider IP address consistency requirements and the potential need to maintain IP addresses after failover and fallback.
    
    -   Consider using [Chaos engineering](https://docs.microsoft.com/en-us/azure/architecture/framework/resiliency/chaos-engineering) as a methodology to enable developers to attain consistent reliability by hardening services against failures in production 

***Design Recommendations***

-   Use multiple regions and ***paired regions*** when planning for BCDR.

      -   Refer to [Azure Region Pairs](https://docs.microsoft.com/en-us/azure/best-practices-availability-paired-regions) documentation when selecting locations for your organizations DR layouts.
    
      -   Planned Azure system updates are rolled out to paired regions sequentially (not at the same time) to minimize downtime, the effect of bugs and logical failures in the rare event of a bad update.
    
      -   In the event of a broad outage, recovery of one region is prioritized out of every pair. Applications that are deployed across paired regions are guaranteed to have one of the regions recovered with priority. If an application is deployed across regions that are not paired, recovery might delayed and worst case the chosen region may be the last two to be recovered.

-   Design network connectivity with High Availability and Disaster Recovery in mind
 
      -   Use multiple peering locations for Express route connectivity. A redundant hybrid network architecture can help ensure uninterrupted cross-premises connectivity in the event of an outage affecting an Azure region or peering provider location.
      
      -   Use Zone redundant platform service with right SKU when designing your architecture for Availability Zone resiliency e.g. Gateway, Load Balancer Standard, WAF etc.
    
      -   Consider [this article](https://docs.microsoft.com/en-us/azure/expressroute/designing-for-disaster-recovery-with-expressroute-privatepeering) when planning and designing for Expressroute Disaster recovery.

      -   Avoid using overlapping IP address ranges for Production and DR sites.

      -   Whenever possible, plan for a BCDR network architect that provides for concurrent connectivity to all sites. DR networks that utilize the same CIDR blocks as production networks will require a network failover process that can complicate and delay application failover in the event of an outage.

-   Employ Azure Site Recovery for Azure to Azure Virtual Machine DR scenarios to replicate workloads across regions.

    -   ASR provides built-in platform capabilities for VM workloads to meet low RPO/RTO requirements through real-time replication and recovery automation. Additionally, the service provides the ability to run recovery drills without affecting the workloads in production.

-   Utilize native PaaS service DR capabilities.

    -   The built-in features provide an easy solution to the complex task of building replication and failover into a workload architecture, simplifying both design and deployment automation. An organization that has defined a standard for the services they use can also audit and enforce the service configuration through Azure Policy.
    
    -   Key Vault is a managed service where certificates, secrets and keys are replicated to a secondary ***paired region***. [Detailed disaster recovery design guidance can be found here](https://docs.microsoft.com/en-us/azure/key-vault/general/disaster-recovery-guidance)


-   Leverage Azure native backup capabilities.

    -   Azure Backup, and PaaS native backup features, remove the need for managing third party backup software and infrastructure. As with other native features, backup configurations can be set, audited, and enforced with Azure Policy, ensuring services remain compliant with organizational requirements.