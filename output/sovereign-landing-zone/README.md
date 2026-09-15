# Assess sovereign controls and plan remediation

This 120-minute lab uses a fictional regulated workload to show how Sovereign Landing Zone design principles, Azure Policy, Azure Resource Graph, and Azure Workbooks support sovereignty assessment and remediation planning.

Learners enforce an approved-region boundary, assess data residency, customer-managed key, and confidential computing controls, build a compliance dashboard, and produce a phased remediation roadmap.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 1: Assess sovereign controls and plan remediation](Instructions/Exercises/01-assess-sovereign-controls-and-plan-remediation.md) | SLZ architecture, policy enforcement, control assessment, dashboard creation, and remediation planning | 120 minutes |

## Lab environment

This portal and Azure CLI lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- A dedicated resource group for each learner.
- An audit-mode initiative named `Contoso Sovereignty Baseline`.
- Policy definition groups and reference IDs for data residency, customer-managed keys, and confidential computing.
- Compliant and noncompliant storage, Key Vault, and virtual machine sample resources.
- Permissions to assign a resource-group policy and save an Azure Workbook.

## Source documentation

- [Sovereign Landing Zone overview](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/overview-slz?tabs=hubspoke)
- [Controls and principles in Sovereign Public Cloud](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/overview-controls-principles)
- [Sovereign Landing Zone implementation options](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/implementation-options)
- [Microsoft Sovereign Cloud MicroHack](https://github.com/microsoft/MicroHack/tree/main/03-Azure/01-03-Infrastructure/01_Sovereign_Cloud)
- [Historical SLZ compliance dashboard extension guidance](https://github.com/Azure/sovereign-landing-zone/blob/main/docs/scenarios/Extending-Compliance-Dashboard.md)

> [!NOTE]
> The original `Azure/sovereign-landing-zone` repository is marked for archival in 2026. This lab uses current Microsoft Learn guidance for SLZ architecture and implementation and retains the repository only as historical dashboard context.