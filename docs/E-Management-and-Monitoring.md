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

# E. Management and Monitoring
[![Management and Monitoring](./media/mgmt-mon.png "Management and Monitoring")](#)

Figure 9 – Platform Management and Monitoring

## 1. Planning for Platform Management and Monitoring

This section will focus on centralized management and monitoring at a platform level, exploring how an entire enterprise Azure estate can be operationally maintained. More specifically, it will consider the key recommendations to support central teams ability to maintain operational visibility of a large-scale Azure platform.

***Design Considerations***

-   A Log Analytics workspace is an administrative boundary.

-   App Centric Platform monitoring, encompassing both hot and cold telemetry paths for metrics and logs respectively

    -   OS metrics (e.g. perf counters, custom metrics)

    -   OS logs (e.g. IIS, ETW, Syslogs)

    -   Resource Health events

-   Security audit logging and achieving a horizontal security lens across the entire customer Azure estate.

    -   Potential integration with on-premises SIEM systems.

    -   Azure Activity Logs

    -   Azure AD audit reports

    -   Azure Diagnostic Service; Diagnostic Logs and metrics, KV audit events, NSG flow and event logs

    -   Azure Monitor, Network Watcher, Security Center, and Azure Sentinel

-   Azure data retention thresholds and requirements for archiving.

    -   The default retention period for Log Analytics is 30 days, with a maximum of 2 years.

    -   The default retention period for Azure AD reports (premium) is 30 days.

    -   The default retention period for the Azure Diagnostic service is 90 days.

-   Operational requirements

    -   Operational dashboarding using native tools, such as Log Analytics, or third party tooling.

    -   Controlling privileged activities with centralized roles.

    -   [Managed identities for Azure resources](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for access to Azure services.

    -   Resource Locks to protect both the deletion and edit of resources.

***Design Recommendations***

-   Use a single [Log Analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment) for centralized platform management except where RBAC, retention of data types and data sovereignty requirements mandate the consideration of separate workspaces.

    Centralized logging is critical to the visibility that's required by the operations management teams. The centralization of logging drives reports about change management, service health, configuration, and most other aspects of IT operations. Converging on a centralized workspace model reduces administrative effort and reduces the chances for gaps in observability.

    Within the context of the Enterprise Scale architecture, centralized logging is primarily concerned with platform operations. However, this does not preclude the use of the same workspace for application logging (VM based). With a workspace configured in resource centric access control mode, granular RBAC is enforced to ensure app teams will only have access to the logs from their resources. In this model app teams benefit from the use of existing platform infrastructure by reducing their management overhead. For any non-compute resources (Web Apps, CosmosDb etc.), application teams can use their own Log Analytics workspaces and enable diagnostics/metrics to be routed here.

-   Export logs to Azure Storage if log retention requirements exceed 2 years.

    -   Leverage immutable storage with WORM policy (Write Once, Read Many) to make data non-erasable and non-modifiable for a user-specified interval.

-   Use Azure Policy for access control and compliance reporting.

    This provides the ability to enforce the settings across an organization to ensure consistent policy adherence and fast violation detection, as described in this [article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects).

-   Monitor in-guest VM configuration drift using Azure Policy.

    Enabling [guest configuration](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/guest-configuration) audit capabilities through policy provides application teams with the ability to immediately consume the feature capabilities for their workloads with very little effort.

-   Use [Update Management in Azure Automation](https://docs.microsoft.com/en-us/azure/automation/automation-update-management) as a long-term patching mechanism, for both Windows and Linux VMs.

    Enforcing configuration of update management through policy ensures all VMs are included in the patch management regimen, provides application teams with the ability to manage patch deployment for their VMs, and provides central IT with visibility and enforcement capabilities across all VMs.

-   Use Azure Network Watcher to proactively monitor traffic flows via [NSG Flow Logs v2](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview).

    The Network Watcher [Traffic Analytics](https://docs.microsoft.com/en-us/azure/network-watcher/traffic-analytics) feature leverages NSG Flow Logs to provide deep insights into IP traffic within a virtual network, providing information critical for effective management and monitoring. Traffic Analytics provides information such as most communicating hosts, most communicating application protocols, most conversing host pairs, allowed/blocked traffic, inbound/outbound traffic, open internet ports, most blocking rules, traffic distribution per Azure datacenter, virtual network, subnets, or, rogue networks.

-   Use resource locks to prevent accidental deletion of critical shared services.

-   Use [deny policies](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deny) to supplement Azure RBAC assignments.

    Deny policies are used to prevent deployment and configuration of resources that do not match defined standards by preventing the request from being sent to the Resource Provider. The combination of deny policies and RBAC assignments ensures the appropriate guard rails are in place to enforce **who** can deploy and configure resources and **what** resources they can deploy and configure.

-   Include [Service](https://docs.microsoft.com/en-us/azure/service-health/service-health-overview) and [Resource](https://docs.microsoft.com/en-us/azure/service-health/resource-health-overview) Health events as part of the overall platform monitoring solution.

    Tracking service and resource health from the platform perspective is an important component of resource management in Azure.

-   Do not send raw logs entries back to on premise monitoring systems, but instead adopt the principal of "data born in Azure, stays in Azure".

    -   If on-premises SIEM integration is required [send critical alerts](https://docs.microsoft.com/en-us/azure/security-center/continuous-export) instead of logs.

## 2. Planning for Application Management and Monitoring

Expanding on the previous section, this next section will now consider the federated management and monitoring of customer application workloads, touching on how application teams can operationally maintain their application workloads.

***Design Considerations***

-   Application monitoring can use dedicated Log Analytics workspaces.

-   For applications that are deployed to virtual machines, logs should be stored centrally to the dedicated Log Analytics workspace from a platform perspective, and application teams can access the logs subject to the RBAC they have on their applications/virtual machines.

-   Application performance and health monitoring for both IaaS and PaaS resources.

-   Data aggregation across all application components.

-   [Health modelling and operationalization](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/manage/monitor/cloud-models-monitor-overview)

    -   How to measure the health of the workload and its subsystems; "traffic light" model for health representation.

    -   How to respond to failures across application components.

***Design Recommendations***

-   Use a centralized Log Analytics workspace to collect logs and metrics from IaaS and PaaS application resources, and [control log access with RBAC](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment#access-control-overview).

-   Use [Azure Monitor Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-platform-metrics) for time sensitive analysis. 

    Metrics in Azure Monitor are stored in a time-series database which is optimized for analyzing time-stamped data. This makes metrics particularly suited for alerting and fast detection of issues. They can tell you how your system is performing but typically need to be combined with logs to identify the root cause of issues.

-   Use [Azure Monitor Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-platform-logs) for insights and reporting. 

    Logs contain different kinds of data organized into records with different sets of properties and are especially useful for performing complex analysis across data from a variety of sources, such as performance data, events, and traces.

-   Use shared storage accounts within the "Landing Zone" for Azure Diagnostic Extension log storage when required.

-   Leverage [Azure Monitor Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-overview) for the generation of operational alerts.

    Azure Monitor Alerts provides a unified experience for alerting on metrics and logs, and leverages features such as action groups and smart groups for advanced management and remediation capabilities.
