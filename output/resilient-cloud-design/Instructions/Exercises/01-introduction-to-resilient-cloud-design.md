---
lab:
    title: 'Lab 1 - L100: Introduction to resilient cloud design'
    description: 'Design and validate Azure VM backup for a regulated Caldova workload by configuring retention, protecting a virtual machine, and verifying a recovery point.'
    level: 100
    duration: 30
    islab: true
    primarytopics:
        - Azure reliability
        - Azure Backup
        - Azure Virtual Machines
        - Recovery Services vault
        - Recovery objectives
        - Shared responsibility
---

# Lab 1 - L100: Introduction to resilient cloud design

Caldova is a pharmaceutical company preparing to launch an accelerated V2 product while closing a 7% production gap across three manufacturing plants. Its supply chain planning application runs on legacy .NET, its manufacturing databases remain on-premises, and its broader application estate runs on VMware that is past renewal. Caldova must modernize without disrupting manufacturing, weakening regulated controls, or putting the product launch at risk.

In this exercise, you begin Caldova's **Start Resilient** journey by translating business requirements into an Azure virtual machine (VM) backup design. You create a Recovery Services vault, configure a retention policy, protect an instructor-provisioned VM that represents the Supply Chain Planning Portal, and verify that Azure Backup produces a validated recovery point. You then assess what the backup design proves and which application-level risks remain.

This exercise should take approximately **30** minutes to complete. The initial backup can continue beyond the exercise time.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with Contributor access to the instructor-provisioned lab resource group.
- Permission to create a Recovery Services vault and an Azure VM backup policy.
- The `Microsoft.RecoveryServices` resource provider registered in the subscription.
- An instructor-provisioned Azure VM with the Azure VM agent installed and running.
- Access to the [Azure portal](https://portal.azure.com/).

> [!IMPORTANT]
> Use only synthetic lab data. Caldova's production GxP batch and quality records must remain in the United Kingdom and require validated access, encryption, policy, and audit controls. Don't place regulated or customer data in the lab VM.

Record the values that your instructor provides:

| Setting | Value |
| --- | --- |
| Subscription |  |
| Resource group |  |
| Azure region |  |
| VM name |  |
| Unique identifier |  |

## Assess Caldova's recovery requirements

Caldova needs business-aligned recovery objectives rather than a backup schedule chosen in isolation. Review the customer requirements and identify where VM backup contributes to resilience and where additional controls are necessary.

1. Review Caldova's current operating context:

    | Requirement or constraint | Business significance |
    | --- | --- |
    | Supply Chain Planning Portal: five-minute continuity target and 500 requests per second | Planning must continue during peak demand. |
    | MES and batch execution: continuous availability | Production runs 24 hours a day. |
    | `BatchManufacturingCore`: maximum 30-minute data-loss tolerance | In-process electronic batch records can't be lost mid-run. |
    | `BatchManufacturingCore` and `QualityLIMS`: UK residency | GxP batch and quality records must remain in the United Kingdom. |
    | No direct internet access from datacenter servers | Protection and monitoring designs must work through approved network paths. |
    | Limited ExpressRoute bandwidth and controlled firewall changes | Transfer time and operational lead time affect recovery planning. |

1. Open the instructor-provisioned VM in the Azure portal.
1. Record its **Location**, **Resource group**, operating system, disk count, and current backup status.
1. Select **Settings** > **Extensions + applications**, and confirm that the Azure VM agent is available.
1. Record the workload represented by the VM and the business process it supports.
1. Identify which Caldova requirement VM backup can help address and which requirements need availability, database protection, disaster recovery, or cyber-recovery controls in addition to backup.

> [!NOTE]
> A recovery time objective (RTO) is the maximum acceptable interruption. A recovery point objective (RPO) is the maximum acceptable data loss measured in time. A daily VM backup doesn't, by itself, meet a five-minute continuity target or a 30-minute database RPO.

## Design the VM backup solution

Use a simple lab policy to learn the protection workflow. Evaluate the policy against Caldova's requirements instead of treating it as a complete production design.

### Define the protection decisions

1. Use these decisions for the lab:

    | Design decision | Lab value | Reason |
    | --- | --- | --- |
    | Vault region | Same region as the VM | A Recovery Services vault protects VMs in its region. |
    | Vault redundancy | Geo-redundant storage (GRS) | Adds a copy in the paired Azure region. |
    | Backup frequency | Daily | Provides a simple introductory schedule. |
    | Daily retention | 30 days | Provides a month of daily recovery points. |
    | Instant Restore retention | Two days | Retains snapshots for faster short-term restore. |

1. Confirm that the selected Azure region and its paired region comply with the lab's data-location requirements.
1. Compare the daily schedule with the Supply Chain Planning Portal continuity target.
1. Record why backup is necessary but insufficient for application availability.
1. Record the additional design decisions required before Caldova uses this pattern for a regulated production workload, including workload-consistent protection, restore testing, encryption, access control, audit evidence, and database-specific recovery.

### Apply shared responsibility

Azure operates the backup service and the physical platform. Caldova remains responsible for choosing policies, assigning access, protecting application dependencies, testing restores, and proving that recovery meets business and regulatory requirements.

1. Assign an owner to each responsibility:

    | Responsibility | Azure or Caldova |
    | --- | --- |
    | Operate the physical infrastructure used by Azure Backup. |  |
    | Choose the backup frequency and retention period. |  |
    | Confirm that the application and database recover consistently. |  |
    | Test restore procedures and collect recovery evidence. |  |
    | Maintain workload access, network paths, and operational runbooks. |  |

1. Confirm that Azure owns operation of the service and Caldova owns workload configuration and recovery validation.

## Create the Recovery Services vault

The Recovery Services vault stores recovery points and manages the VM backup policy. Configure its storage redundancy before you protect the VM because the option becomes restricted after the vault contains protected items.

1. In the Azure portal, enter **Resiliency** in the search box, and then select **Resiliency**.
1. On the **Vault** pane, select **+ Vault**.
1. Select **Recovery Services vault**, and then select **Continue**.
1. Enter the following values:

    | Setting | Value |
    | --- | --- |
    | **Subscription** | *{lab subscription}* |
    | **Resource group** | *{lab resource group}* |
    | **Vault name** | `rsv-caldova-<unique-id>-<region>` |
    | **Region** | *{same region as the VM}* |

1. Select **Review + create**, and then select **Create**.
1. Open the deployed vault, and then select **Settings** > **Properties**.
1. Under **Backup Configuration**, select **Update**, select **Geo-redundant**, and then select **Save**.

Confirm that **Backup Configuration** displays **Geo-redundant** before you continue.

> [!NOTE]
> Geo-redundant vault storage doesn't automatically make the application available in another region. Cross-region recovery also depends on supported vault settings, replicated application dependencies, networking, identity, capacity, and a tested recovery plan.

## Configure the VM backup policy

Create a policy that implements the lab's backup frequency and retention decisions.

1. In the Recovery Services vault, select **Manage** > **Backup policies**.
1. Select **+ Add**, and then select **Azure Virtual Machine**.
1. Enter `bp-caldova-vm-daily-30d` for **Policy name**.
1. Set **Policy subtype** to **Standard** and **Backup frequency** to **Daily**. Choose a time that doesn't overlap with other lab operations.
1. Retain the daily recovery point for **30 days**.
1. Set **Instant Restore** snapshot retention to **2 days**.
1. Select **Create**, and confirm that the policy appears in the policy list.

> [!TIP]
> A production workload that needs recovery points more often than once each day might require an Enhanced policy or workload-specific protection. Validate service support, cost, and application consistency before choosing a policy.

## Protect and validate the VM

Apply the policy, start an on-demand backup, and inspect each phase of the backup job. A successful configuration isn't enough. Recovery readiness requires a completed, validated recovery point and a tested restore procedure.

### Enable VM protection

1. Return to **Resiliency**, and then select **+ Configure protection**.
1. Set **Resources managed by** to **Azure**, **Datasource type** to **Azure Virtual machines**, and **Solution** to **Azure Backup**. Then select **Continue**.
1. Select the Recovery Services vault, select **Continue**, and assign `bp-caldova-vm-daily-30d`.
1. Under **Virtual Machines**, select **Add**, select the instructor-provisioned VM, and then select **OK**.
1. Select **Enable backup**, and wait for the configuration operation to complete.
1. Select **Protected items** in **Resiliency**, filter **Datasource type** to **Azure Virtual machines**, and confirm that the VM appears with protection enabled.

### Create and monitor a recovery point

1. Open the protected VM in the vault.
1. Select **Backup now**.
1. Choose the default retention date for the on-demand recovery point, and then select **OK**.
1. Select **Jobs** in **Resiliency**, and open the VM backup job.
1. Monitor or record the status of these phases:

    | Phase | Expected result |
    | --- | --- |
    | Snapshot | Azure Backup captures the VM disks for Instant Restore. |
    | Transfer data to vault | Azure Backup transfers backup data for vault retention. |
    | Validate backup | Azure Backup verifies the recovery point. |

1. After the job succeeds, return to the protected VM and select **Recovery points**.
1. Confirm that the new recovery point appears with its date, time, and consistency type.

> [!IMPORTANT]
> The initial backup can take longer than the exercise, depending on VM size and data churn. If it remains in progress, record the job ID and current phase. A completed transfer alone doesn't prove recovery readiness. Continue validation after **Validate backup** succeeds.

## Evaluate recovery readiness

Connect the technical result to Caldova's business and regulatory requirements. This review prevents a green backup status from being mistaken for complete workload resilience.

1. Record the evidence produced by the lab:

    | Evidence | Observation |
    | --- | --- |
    | Vault region and redundancy |  |
    | Applied policy and retention |  |
    | Protected VM |  |
    | Backup job ID and final status |  |
    | Recovery point time and consistency type |  |

1. Determine whether the policy meets the Supply Chain Planning Portal's five-minute continuity target.
1. Explain why the VM recovery point doesn't prove that `BatchManufacturingCore` can meet its 30-minute data-loss tolerance.
1. Identify the evidence Caldova still needs before production approval, such as an isolated restore test, application validation, database consistency checks, measured recovery time, audit records, and an approved runbook.
1. Recommend one next control for each gap:

    | Gap | Example next control |
    | --- | --- |
    | Application availability during a VM or zone failure | Use a redundant application architecture and test failover. |
    | Database recovery within the required RPO | Use database-aware backup or replication with validated recovery objectives. |
    | Regional disruption | Design and test a regional disaster-recovery path. |
    | Ransomware or compromised credentials | Protect recovery data with immutability, least privilege, and cyber-recovery validation. |
    | UK residency and regulatory evidence | Validate data locations and retain auditable policy and recovery evidence. |

1. Summarize whether the VM is **backed up**, **restorable**, and **proven to meet the business requirement**. Treat these as three separate conclusions.

## Summary

In this exercise, you translated Caldova's business constraints into an introductory VM backup design. You created a geo-redundant Recovery Services vault, configured a daily retention policy, protected an Azure VM, and inspected a validated recovery point. You also identified the application availability, database recovery, regional recovery, cyber-recovery, and compliance evidence that backup alone doesn't provide.

You have successfully completed this exercise.

## Clean up

Remove only the backup resources that you created. Don't delete the instructor-provisioned VM or resource group.

1. Open `rsv-caldova-<unique-id>-<region>`.
1. Select **Protected items** > **Backup items** > **Azure Virtual Machine**, and then open the protected VM.
1. Select **Stop backup**, select **Delete backup data**, enter the requested confirmation, and confirm the operation.
1. Wait for Azure Backup to remove the protected item.
1. Delete `bp-caldova-vm-daily-30d` if Azure doesn't remove it with the vault.
1. Delete `rsv-caldova-<unique-id>-<region>`.

> [!NOTE]
> Vault deletion can remain blocked while backup data is soft-deleted or an operation is in progress. Don't disable subscription-level safety features to accelerate lab cleanup. Record the vault name and ask the instructor to complete deletion when necessary.

## Learn more

- [Azure Backup architecture and components](/azure/backup/backup-architecture)
- [Back up Azure VMs in a Recovery Services vault](/azure/backup/backup-azure-arm-vms-prepare)
- [Azure VM backup policies](/azure/backup/backup-azure-vms-introduction#backup-and-restore-considerations)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)
- [Sovereign Landing Zone overview](https://github.com/Azure/sovereign-landing-zone/blob/main/docs/01-Overview.md)
