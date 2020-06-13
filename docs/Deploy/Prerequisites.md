# Navigation Menu

* [Overview](../../README.md)
* [North Star Architecture](../NorthStar-Architecture.md)
  * [Design Principles](../Design-Principles.md)
  * [Design Guidelines](../Design-Guidelines.md)
    * [A - Enterprise Enrollment and Azure AD Tenants](../A-Enterprise-Enrollment-and-Azure-AD-Tenants.md)
    * [B - Identity and Access Management](../B-Identity-and-Access-Management.md)
    * [C - Management Group and Subscription Organization](../C-Management-Group-and-Subscription-Organization.md)
    * [D - Network Topology and Connectivity](../D-Network-Topology-and-Connectivity.md)
    * [E - Management and Monitoring](../E-Management-and-Monitoring.md)
    * [F - Business Continuity and Disaster Recovery](../F-Business-Continuity-and-Disaster-Recovery.md)
    * [G - Security, Governance and Compliance](../G-Security-Governance-and-Compliance.md)
    * [H - Platform Automation and DevOps](../H-Platform-Automation-and-DevOps.md)
  * [Implementation Guide](../Implementation-Guide.md)
* [Contoso Reference](../Contoso/Readme.md)
  * [Scope and Design](../Contoso/Scope.md)
  * [Implementation](../Contoso/Design.md)
* [Using reference implementation in your own environment](./Readme.md)
  * [Getting started](./Getting-Started.md)
    * [Prerequisites](./Prerequisites.md)
    * [Validate prerequisites](./Validate-prereqs.md)
  * [Configure your own environment](./Using-Reference-Implementation.md)
    * [Configure GitHub](./Configure-run-initialization.md)
    * [Provision Platform](./Deploy-platform-infra.md)
    * [Create Landing Zones](./Deploy-lz.md)
    * [Trigger deployments locally](./Trigger-local-deployment.md)
  * [North Star ARM template](./NorthStar-schema.md)
  * [Known Issues](./Known-Issues.md)
* [How Do I Contribute?](../Northstar-Contribution.md)
* [FAQ](../Northstar-FAQ.md)
* [Roadmap](../Northstar-roadmap.md)

---

## Prerequisites

This table lists the technical prerequisites needed to use the NorthStar reference implementation. We have chosen to base the reference implementation on PowerShell, but if desired, it is perfectly possible to use other tools such as e.g. Azure CLI for deployment operations.

|Requirement|Additional info | |
|---------------|--------------------|--------------------|
|Git >= 2.1| Latest version of git can be found [here](https://git-scm.com/). <br/> <br/> Run following command from command prompt to ensure your Git is correctly configured. You may be prompted for login that may require you to sign in with MFA. <br/> <br/>```git clone https://github.com/Azure/CET-NorthStar.git ``` | [Git handbook](https://guides.github.com/introduction/git-handbook/)|
| VSCode |  Latest version of VSCode. <br/><br/> Open the directory ```CET-NorthStar``` cloned from previous step inside VSCode and run ```git pull``` command to ensure Git Credentials are setup correctly in VSCode. <br/> <br/> Exit VSCode and delete ```CET-NorthStar``` directory as it will no longer be required. | [Install](https://code.visualstudio.com/download#)  |
Minimum version of PowerShell: 7.0|  The latest version of PowerShell including install instructions can be found [here](https://github.com/PowerShell/PowerShell). <br> Confirm the version of PowerShell that you are running by typing `$PSVersionTable` in a PowerShell session.| [Instructions](https://github.com/PowerShell/PowerShell)
|Az.Accounts >= 1.8 <br>Az.Resources >= 2.0.1 |  `Install-Module -Name Az.<ModuleName> -MinimumVersion <Version> -Scope AllUsers`<br>Confirm the version of the module you have by running <br>`Get-Module Az.<ModuleName> -ListAvailable`. | [Docs](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)|
| Pester >= 4.10.1 |  ***Only required if you want to run pester-tests as a developer*** <br>`Install-Module -Name Pester -MinimumVersion 4.10.1 -Scope AllUsers`<br> You can confirm the version of the module you have by running <br>`Get-Module Pester -ListAvailable`. | [Docs](https://github.com/pester/Pester) |


>  :iphone: If you have Multi-factor authentication (MFA) enabled on any of your accounts, make sure that you have your token app/phone easily accessible before you start.

## Fork the CET-NorthStar repo to your GitHub account

Login to GitHub in your web browser using your private account (that was onboarded to `Azure` organization), and [fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) `Azure/CET-NorthStar` repository to your account. This will allow you to contribute to this repository with Pull Requests and standard GitHub Flow.

## Clone the repository to your local machine

In your local machine, open the Command prompt, navigate to a directory, where you typically keep your code, and run the following command (replace <yourAccount> with your GitHub account name).

```shell
git clone https://github.com/<yourAccount>/CET-NorthStar.git
```

## Sync your fork with upstream repo

Follow these steps in order to synchronize the latest changes from the upstream repo into your local fork.

1) Run the following git commands only once you change your directory to your local fork to add a reference to the upstream repo

    ```shell
    git remote -v
    git remote add upstream https://github.com/Azure/CET-NorthStar.git
    git remote -v
    ```

2) Execute the following git commands only when you need to synchronize changes from upstream repo into your local fork:

    ```shell
    git fetch upstream
    git merge upstream/master
    ```

