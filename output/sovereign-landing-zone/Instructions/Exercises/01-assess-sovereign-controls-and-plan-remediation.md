---
lab:
    title: 'Lab 1: Assess sovereign controls and plan remediation'
    description: 'Enforce a regional control, assess data residency, customer-managed key, and confidential computing compliance, build a sovereignty dashboard, and prioritize remediation.'
    level: 300
    duration: 120
    islab: true
    primarytopics:
        - Sovereign Landing Zone
        - Azure Policy
        - Azure Resource Graph
        - Azure Workbooks
        - Azure Key Vault
        - Azure Confidential Computing
---

# Lab 1: Assess sovereign controls and plan remediation

Contoso operates regulated workloads in Azure and must demonstrate where data is stored, who controls encryption keys, and whether sensitive processing can use confidential computing. The organization has an Azure landing zone, but its governance team needs evidence of the current posture before it layers additional Sovereign Landing Zone (SLZ) controls onto the environment.

In this exercise, you examine the SLZ architecture, enforce one sovereign control in an isolated resource group, and assess three foundational control families. You then create an Azure Workbook that consolidates Azure Policy evidence and use the findings to produce a prioritized remediation roadmap.

This exercise should take approximately **120** minutes to complete.

> [!IMPORTANT]
> SLZ is an architectural variant of Azure landing zones, not a certification or a guarantee of legal compliance. Your organization remains responsible for interpreting applicable laws, validating service data-handling characteristics, approving policy effects, and documenting exceptions.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with an instructor-provisioned resource group named `rg-sovereignty-lab-<unique-id>`.
- **Contributor** and **Resource Policy Contributor** access to the lab resource group.
- Permission to create and save an Azure Workbook in the lab resource group.
- Access to the [Azure portal](https://portal.azure.com/).
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) version 2.60 or later, or Azure Cloud Shell.
- The `resource-graph` Azure CLI extension. Azure CLI installs the extension automatically when you first run `az graph` if dynamic extension installation is enabled.
- An instructor-assigned audit initiative named `Contoso Sovereignty Baseline` with policy definition groups and reference IDs that begin with these values:

    | Control family | Initiative group name | Reference ID prefix |
    | --- | --- | --- |
    | Data residency | `so.1 - data residency` | `so.1-` |
    | Customer-managed keys | `so.3 - customer-managed keys` | `so.3-` |
    | Confidential computing | `so.4 - azure confidential computing` | `so.4-` |

- Instructor-provisioned compliant and noncompliant sample resources in the lab resource group, including storage, Key Vault, and virtual machine resources.

Record the values that your instructor provides:

| Setting | Value |
| --- | --- |
| Subscription ID |  |
| Lab resource group | `rg-sovereignty-lab-<unique-id>` |
| Approved Azure regions |  |
| Unique identifier |  |

> [!NOTE]
> Azure Policy results can take several minutes to update. A resource with no policy state isn't evidence of compliance; confirm that the resource is in scope and applicable to at least one policy definition.

## Understand the Sovereign Landing Zone

Start by relating Contoso's requirements to the current SLZ architecture. SLZ layers sovereign design choices and policies onto an Azure landing zone and can be adopted incrementally.

1. Open the [Sovereign Landing Zone overview](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/overview-slz?tabs=hubspoke).
1. Review the hub-and-spoke, Virtual WAN, and management-group views.
1. Identify the `Public`, `Confidential Corp`, and `Confidential Online` management groups added beneath the landing zones management group.
1. Review the [Sovereign Landing Zone implementation options](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/implementation-options).
1. Record why Contoso can layer SLZ controls onto its existing landing zone instead of replacing the landing zone.
1. Map the prepared control families to these protection goals:

    | Protection goal | Control family | Example evidence |
    | --- | --- | --- |
    | Keep regulated data within approved geographic boundaries | Data residency | Resource location and Azure Policy state |
    | Retain control over keys used to encrypt stored data | Customer-managed keys | Encryption configuration and policy state |
    | Protect data while it is processed | Confidential computing | Supported confidential SKU, security type, and policy state |

Confirm that the architecture separates workload classifications and applies stricter controls as sensitivity increases.

## Enforce sovereign controls

Use a resource-group-scoped assignment to prevent deployments outside Contoso's approved regions. Keep this control isolated from shared subscriptions and management groups.

### Establish the command-line context

1. Open Azure Cloud Shell in Bash mode or a local terminal with Azure CLI installed.
1. Sign in to Azure by running the following command. This command opens an interactive sign-in flow.

    ```azurecli
    az login
    ```

1. Set the subscription and lab resource group by running the following commands. These variables constrain the later queries and changes to the lab environment.

    ```bash
    SUBSCRIPTION_ID="<subscription-id>"
    RESOURCE_GROUP="rg-sovereignty-lab-<unique-id>"
    az account set --subscription "$SUBSCRIPTION_ID"
    SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
    ```

1. Verify the context by running the following command. The output should show the expected subscription name and ID.

    ```azurecli
    az account show --query "{name:name,id:id,tenantId:tenantId}" --output table
    ```

### Assign the allowed locations policy

1. Open **Policy** in the Azure portal.
1. Select **Authoring** > **Assignments**, and then select **Assign policy**.
1. Set **Scope** to `rg-sovereignty-lab-<unique-id>`.
1. Select the built-in policy definition **Allowed locations**.
1. Enter `Enforce approved sovereign regions` for **Assignment name**.
1. Select **Next** until the **Parameters** tab appears.
1. Select only the approved regions supplied by your instructor for **Allowed locations**.
1. Select **Review + create**, and then select **Create**.
1. Open the assignment and confirm that **Enforcement mode** is **Enabled** and the policy effect is `deny`.

> [!IMPORTANT]
> Region restrictions don't prove data residency by themselves. Global services and some regional services can replicate or process data outside a selected region. Validate each service against its current data residency documentation.

### Test the enforcement boundary

1. Choose a region that isn't in the approved list and set `DISALLOWED_LOCATION` to its Azure CLI name.
1. Run the following command to attempt a storage account deployment outside the approved boundary. The command uses a globally unique name and should fail with a policy violation.

    ```bash
    DISALLOWED_LOCATION="<disallowed-region>"
    STORAGE_NAME="slzdeny${RANDOM}${RANDOM}"
    az storage account create \
      --name "$STORAGE_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --location "$DISALLOWED_LOCATION" \
      --sku Standard_LRS
    ```

1. Confirm that the output includes `RequestDisallowedByPolicy` and identifies **Enforce approved sovereign regions**.
1. If the deployment succeeds, delete the test storage account by running the following command. A new policy assignment can take several minutes to become effective, so wait five minutes and repeat the test after cleanup.

        ```azurecli
        az storage account delete \
            --name "$STORAGE_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --yes
        ```

1. Open **Policy** > **Compliance**, select the assignment, and review its scope and parameters.

You have enforced a sovereign deployment boundary without changing shared governance scopes.

## Assess data residency compliance

Assess both policy state and service behavior. Location metadata identifies where a resource is deployed, but a valid residency conclusion also depends on how each service stores, replicates, backs up, and processes customer data.

1. Open **Resource Graph Explorer** in the Azure portal.
1. Set the query scope to the lab subscription.
1. Enter the following query. It returns the latest data residency policy state for resources in the lab resource group.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.policyinsights/policystates'
    | extend resourceId = tostring(properties.resourceId),
        resourceGroupName = tostring(properties.resourceGroup),
        referenceId = tostring(properties.policyDefinitionReferenceId),
        complianceState = tostring(properties.complianceState),
        resourceLocation = tostring(properties.resourceLocation),
        policyName = tostring(properties.policyDefinitionName)
    | where resourceGroupName =~ 'rg-sovereignty-lab-<unique-id>'
    | where referenceId startswith 'so.1-'
    | summarize arg_max(timestamp, *) by resourceId, referenceId
    | project resourceId, resourceLocation, complianceState, policyName
    | order by complianceState desc, resourceId asc
    ```

1. Replace `<unique-id>` with your assigned value, and then select **Run query**.
1. Confirm that the results include both compliant and noncompliant prepared resources.
1. Select one noncompliant resource and open its **Policy compliance** details.
1. Record the policy definition, evaluated expression, current value, expected value, and timestamp.
1. Classify each observed service as **Regional**, **Global**, or **Requires service-level review** by using the service's current data residency documentation.
1. Record the findings in this table:

    | Resource | Policy state | Deployed location | Service classification | Replication or processing question | Evidence gap |
    | --- | --- | --- | --- | --- | --- |
    |  |  |  |  |  |  |

Confirm that every noncompliant result has a traceable policy reason and that every compliant result still has a documented service-level residency review.

## Assess customer-managed key compliance

Use the prepared `so.3` controls to distinguish platform-managed encryption from customer-managed key (CMK) protection. Azure encrypts data at rest by default, but CMKs add customer control and operational responsibilities such as rotation, access governance, and recovery.

1. Return to **Resource Graph Explorer**.
1. Replace the editor contents with the following query. It summarizes CMK compliance by policy and retains a count of distinct affected resources.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.policyinsights/policystates'
    | extend resourceGroupName = tostring(properties.resourceGroup),
        referenceId = tostring(properties.policyDefinitionReferenceId),
        complianceState = tostring(properties.complianceState),
        policyName = tostring(properties.policyDefinitionName),
        resourceId = tostring(properties.resourceId)
    | where resourceGroupName =~ 'rg-sovereignty-lab-<unique-id>'
    | where referenceId startswith 'so.3-'
    | summarize arg_max(timestamp, *) by resourceId, referenceId
    | summarize resources = dcount(resourceId) by policyName, complianceState
    | order by complianceState desc, policyName asc
    ```

1. Replace `<unique-id>`, and then select **Run query**.
1. Open one compliant storage resource and review **Encryption**.
1. Confirm that the encryption type identifies a customer-managed key and records a Key Vault or managed HSM key identifier.
1. Open the referenced key store and review soft delete, purge protection, key expiration, rotation policy, and role assignments without changing them.
1. Open one noncompliant resource and identify whether remediation is supported in place or requires migration or redeployment.
1. Record the findings in this table:

    | Resource | CMK state | Key store | Rotation evidence | Identity dependency | Remediation approach |
    | --- | --- | --- | --- | --- | --- |
    |  |  |  |  |  |  |

> [!NOTE]
> A CMK configuration can fail if the key is disabled, deleted, expired, inaccessible, or unavailable. Treat key lifecycle, identity, networking, backup, and break-glass procedures as workload dependencies.

Confirm that each CMK finding includes both the policy result and the operational dependencies required to keep encrypted data available.

## Assess confidential computing readiness

Treat confidential computing as a progressive control. Measure workload compatibility, regional SKU availability, quota, attestation requirements, and operational constraints before changing a policy effect from `audit` to `deny`.

1. Return to **Resource Graph Explorer**.
1. Replace the editor contents with the following query. It combines prepared `so.4` policy states with virtual machine configuration.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.policyinsights/policystates'
    | extend resourceGroupName = tostring(properties.resourceGroup),
        referenceId = tostring(properties.policyDefinitionReferenceId),
        complianceState = tostring(properties.complianceState),
        resourceId = tolower(tostring(properties.resourceId)),
        policyName = tostring(properties.policyDefinitionName)
    | where resourceGroupName =~ 'rg-sovereignty-lab-<unique-id>'
    | where referenceId startswith 'so.4-'
    | summarize arg_max(timestamp, *) by resourceId, referenceId
    | join kind=leftouter (
        Resources
        | where type =~ 'microsoft.compute/virtualmachines'
        | project resourceId = tolower(id), location,
            vmSize = tostring(properties.hardwareProfile.vmSize),
            securityType = tostring(properties.securityProfile.securityType)
      ) on resourceId
    | project resourceId, location, vmSize, securityType, complianceState, policyName
    | order by complianceState desc, resourceId asc
    ```

1. Replace `<unique-id>`, and then select **Run query**.
1. Compare the standard and confidential virtual machine results.
1. Open the prepared confidential VM and review **Configuration** without changing it.
1. Confirm the VM size, security type, Secure Boot state, virtual Trusted Platform Module state, and OS disk encryption configuration.
1. Review the [Azure confidential computing product offering](https://learn.microsoft.com/azure/confidential-computing/overview-azure-products) and confirm whether the workload's Azure service and region support the required trusted execution environment.
1. Record each readiness dimension:

    | Workload | Supported service or SKU | Region and quota | Image compatibility | Attestation need | Readiness |
    | --- | --- | --- | --- | --- | --- |
    |  |  |  |  |  | Ready / Conditional / Not ready |

Confirm that no workload is marked **Ready** based only on a compliant policy state.

## Build a sovereignty compliance dashboard

Create an Azure Workbook that gives governance teams a repeatable view of the three sovereign control families. The historical SLZ dashboard used initiative groups named `so.1`, `so.3`, and `so.4`; this lab uses the prepared reference ID prefixes to expose the same logical views with current Azure Policy data.

1. Open **Azure Monitor** in the Azure portal.
1. Select **Workbooks**, and then select **New**.
1. Select **Add** > **Add query**.
1. Set **Data source** to **Azure Resource Graph** and **Resource type** to **Subscriptions**.
1. Enter the following query. It returns one row per control family and compliance state.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.policyinsights/policystates'
    | extend resourceGroupName = tostring(properties.resourceGroup),
        referenceId = tostring(properties.policyDefinitionReferenceId),
        complianceState = tostring(properties.complianceState),
        resourceId = tostring(properties.resourceId)
    | where resourceGroupName =~ 'rg-sovereignty-lab-<unique-id>'
    | extend controlFamily = case(
        referenceId startswith 'so.1-', 'Data residency',
        referenceId startswith 'so.3-', 'Customer-managed keys',
        referenceId startswith 'so.4-', 'Confidential computing',
        'Other')
    | where controlFamily != 'Other'
    | summarize arg_max(timestamp, *) by resourceId, referenceId
    | summarize resourceCount = dcount(resourceId) by controlFamily, complianceState
    | order by controlFamily asc, complianceState asc
    ```

1. Replace `<unique-id>`, select **Run query**, and set **Visualization** to **Bar chart**.
1. Set **Chart title** to `Sovereignty posture by control family`, and then select **Done Editing**.
1. Add a second Azure Resource Graph query that lists the noncompliant resources and policy names. This query provides drill-down evidence for the summary chart.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.policyinsights/policystates'
    | extend resourceGroupName = tostring(properties.resourceGroup),
        referenceId = tostring(properties.policyDefinitionReferenceId),
        complianceState = tostring(properties.complianceState),
        resourceId = tostring(properties.resourceId),
        policyName = tostring(properties.policyDefinitionName)
    | where resourceGroupName =~ 'rg-sovereignty-lab-<unique-id>'
    | where referenceId startswith 'so.1-'
        or referenceId startswith 'so.3-'
        or referenceId startswith 'so.4-'
    | where complianceState == 'NonCompliant'
    | summarize arg_max(timestamp, *) by resourceId, referenceId
    | project resourceId, referenceId, policyName, timestamp
    | order by referenceId asc, resourceId asc
    ```

1. Replace `<unique-id>`, select **Run query**, set **Visualization** to **Grid**, and set **Title** to `Noncompliant resources`.
1. Add a third Azure Resource Graph query for policy exemptions. Exemptions must remain visible because an exempt resource isn't the same as a resource that satisfies the policy rule.

    ```kusto
    PolicyResources
    | where type =~ 'microsoft.authorization/policyexemptions'
    | extend displayName = tostring(properties.displayName),
        assignmentId = tostring(properties.policyAssignmentId),
        category = tostring(properties.exemptionCategory),
        expiresOn = todatetime(properties.expiresOn)
    | where id contains '/resourceGroups/rg-sovereignty-lab-<unique-id>/'
    | project displayName, category, expiresOn, assignmentId
    | order by expiresOn asc
    ```

1. Replace `<unique-id>`, select **Run query**, set **Visualization** to **Grid**, and set **Title** to `Policy exemptions`.
1. Select **Save**, and save the workbook as `Sovereignty Compliance - <unique-id>` in the lab resource group.
1. Reopen the saved workbook and confirm that all three views load without query errors.

> [!TIP]
> A blank exemptions grid is a valid result when the lab scope has no exemptions. Keep the view so future exemptions become visible.

## Create a sovereignty remediation roadmap

Convert the technical findings into sequenced work. Prioritize control gaps by data sensitivity and exposure, and account for application changes, regional capacity, key availability, cost, and downtime.

1. Export the `Noncompliant resources` grid from the workbook or use it as the source for your assessment.
1. Remove duplicate findings that describe the same root cause on the same resource.
1. Assign each remaining finding a severity by using this rubric:

    | Severity | Criteria |
    | --- | --- |
    | Critical | Restricted data is outside an approved boundary, exposed without an approved exception, or cannot meet a mandatory control. |
    | High | A mandatory CMK or confidential computing control is absent from a sensitive production workload. |
    | Medium | A control can be met but requires planned migration, quota, application validation, or downtime. |
    | Low | Evidence, metadata, monitoring, ownership, or documentation is incomplete. |

1. Create a roadmap with the following columns:

    | Priority | Finding | Control family | Proposed action | Owner | Dependency | Validation | Target phase |
    | ---: | --- | --- | --- | --- | --- | --- | --- |
    | 1 |  |  |  |  |  |  | 0-30 days |
    | 2 |  |  |  |  |  |  | 31-60 days |
    | 3 |  |  |  |  |  |  | 61-90 days |

1. Place evidence corrections, unsupported-service decisions, and urgent exposure reduction in the **0-30 days** phase.
1. Place in-place CMK configuration and low-risk regional changes in the **31-60 days** phase after testing and approval.
1. Place workload migrations, confidential compute adoption, and architecture changes in the **61-90 days** phase or a later program increment.
1. Add a rollback or contingency approach for every action that changes a production resource.
1. Add an explicit approval gate before changing an initiative effect from `audit` to `deny`.
1. Review the roadmap with a partner and confirm that each item has an owner, evidence-based validation step, and target phase.

The roadmap now separates immediate governance corrections from changes that require workload engineering and formal risk acceptance.

## Summary

In this exercise, you related sovereign requirements to the current SLZ architecture, enforced an approved-region boundary, and assessed data residency, CMK, and confidential computing controls. You built a workbook from Azure Policy data and converted the resulting evidence into a phased remediation roadmap.

You have successfully completed this exercise.

## Clean up

Remove only the policy assignment and workbook that you created. Don't delete the instructor-provisioned initiative or sample resources.

1. Open **Policy** > **Assignments** in the Azure portal.
1. Set the scope filter to `rg-sovereignty-lab-<unique-id>`.
1. Select **Enforce approved sovereign regions**, and then select **Delete assignment**.
1. Confirm the deletion.
1. Open **Azure Monitor** > **Workbooks**.
1. Select `Sovereignty Compliance - <unique-id>`, and then select **Delete**.
1. Confirm that the assignment and workbook no longer appear.
1. Close Cloud Shell or the local terminal session.

## Learn more

- [Sovereign Landing Zone overview](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/overview-slz?tabs=hubspoke)
- [Controls and principles in Sovereign Public Cloud](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/overview-controls-principles)
- [Sovereign Landing Zone implementation options](https://learn.microsoft.com/industry/sovereign-cloud/sovereign-public-cloud/sovereign-landing-zone/implementation-options)
- [Get Azure Policy compliance data](https://learn.microsoft.com/azure/governance/policy/how-to/get-compliance-data)
- [Azure Resource Graph sample queries for Azure Policy](https://learn.microsoft.com/azure/governance/resource-graph/samples/samples-by-category#azure-policy)
- [Azure confidential computing products](https://learn.microsoft.com/azure/confidential-computing/overview-azure-products)
- [Services that support customer-managed keys](https://learn.microsoft.com/azure/security/fundamentals/encryption-customer-managed-keys-support)
- [Historical SLZ compliance dashboard extension guidance](https://github.com/Azure/sovereign-landing-zone/blob/main/docs/scenarios/Extending-Compliance-Dashboard.md)
