---
lab:
    title: 'Lab 4: Protect Azure data and recover from cyber threats'
    description: 'Use Azure Backup to protect an Azure virtual machine and Blob Storage data, harden recovery points, and assess recovery point health.'
    level: 300
    duration: 70
    islab: true
    primarytopics:
        - Azure Backup
        - Azure Virtual Machines
        - Azure Blob Storage
        - Microsoft Defender for Cloud
        - Cyber recovery
---

# Lab 4: Protect Azure data and recover from cyber threats

Contoso Financial Services runs an insurance claims application on Azure. The application tier runs on an Azure virtual machine (VM), while scanned claim documents and logs reside in Azure Blob Storage. Neither workload is protected, so an accidental deletion, failed deployment, or ransomware incident could interrupt claims processing and leave the business without a trusted recovery path.

In this exercise, you use Azure Backup to protect both workloads. You configure a Recovery Services vault for the VM and a Backup vault for the storage account, validate recovery points, enable reversible immutability, and use Microsoft Defender for Cloud signals to assess whether VM recovery points are suitable for recovery.

This exercise should take approximately **70** minutes to complete.

> [!NOTE]
> Threat detection for Azure VM backups is in preview. Portal labels, regional availability, and behavior can change. The feature isn't available in UAE Central, Israel Central, Qatar Central, or Israel North West.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with Contributor access to the instructor-provisioned lab resource group.
- Permission to create vaults and backup policies and to assign Azure roles.
- The `Microsoft.RecoveryServices` and `Microsoft.DataProtection` resource providers registered in the subscription.
- An instructor-provisioned Azure VM named `ContosoClaimsApp-VM1` with the Azure VM agent installed and running.
- An instructor-provisioned storage account named `ContosoClaimsApp-SA1` with at least one container and sample blobs.
- Microsoft Defender for Servers Plan 1 or Plan 2 enabled for the lab VM.
- Access to the [Azure portal](https://portal.azure.com/).

> [!IMPORTANT]
> Create both vaults in the same region as the resources they protect. Don't enable locked immutability in this exercise. Locked immutability is irreversible and can prevent lab cleanup.

Record the values that your instructor provides:

| Setting | Value |
| --- | --- |
| Subscription |  |
| Resource group |  |
| Azure region |  |
| VM name | `ContosoClaimsApp-VM1` |
| Storage account name | `ContosoClaimsApp-SA1` |
| Unique identifier |  |

## Protect the claims application VM

Start by translating Contoso's recovery requirements into a backup policy. You then create a Recovery Services vault, protect the VM, and verify that Azure Backup creates a usable recovery point.

### Define the VM recovery requirements

Use these requirements throughout the VM protection workflow:

| Requirement | Lab decision |
| --- | --- |
| Recovery point objective (RPO) | One backup each day |
| Daily retention | 30 days |
| Instant Restore retention | Two days |
| Regional recovery | Use geo-redundant storage (GRS) |

1. Open `ContosoClaimsApp-VM1` in the Azure portal.
1. Record the VM's **Resource group** and **Location**.
1. Select **Settings** > **Extensions + applications**, and confirm that the Azure Backup extension can use the Azure VM agent.
1. Compare the lab decisions with the workload's business requirements.
1. Record any requirement that the daily policy doesn't meet.

> [!NOTE]
> If a production workload needs backups more often than once each day, evaluate an Enhanced policy. Enhanced policies support backup intervals as short as four hours and can increase snapshot costs.

### Create the Recovery Services vault

The Recovery Services vault stores and manages recovery points for the VM. Set its replication type before you protect any items because you can't change the type after the vault contains backup data.

1. Enter **Resiliency** in the Azure portal search box, and then select **Resiliency**.
1. Select **+ Vault** on the **Vault** pane.
1. Select **Recovery Services vault**, and then select **Continue**.
1. Enter the following values:

    | Setting | Value |
    | --- | --- |
    | **Subscription** | *{lab subscription}* |
    | **Resource group** | *{lab resource group}* |
    | **Vault name** | `rsv-lab-<unique-id>-<region>` |
    | **Region** | *{same region as the VM}* |

1. Select **Review + create**, and then select **Create**.
1. Open the deployed vault, and then select **Settings** > **Properties**.
1. Select **Update** under **Backup Configuration**, select **Geo-redundant**, and then select **Save**.

Confirm that the **Backup Configuration** section displays **Geo-redundant** before you continue.

### Configure the VM backup policy

Apply the recorded RPO and retention requirements through a custom Standard backup policy.

1. Select **Manage** > **Backup policies** in the Recovery Services vault.
1. Select **+ Add**, and then select **Azure Virtual Machine**.
1. Enter `bp-vm-claims-daily-30d` for **Policy name**.
1. Set **Policy subtype** to **Standard** and **Backup frequency** to **Daily**.
1. Set daily recovery point retention to **30 days**.
1. Set **Instant Restore** snapshot retention to **2 days**.
1. Select **Create**, and confirm that the policy appears in the policy list.

> [!NOTE]
> Azure VM backup schedules don't adjust automatically for daylight-saving time. Review production schedules when local clocks change.

### Enable and verify VM protection

Attach the policy to the claims application VM, run an on-demand backup, and monitor all backup phases.

1. Return to **Resiliency**, and then select **+ Configure protection**.
1. Set **Resources managed by** to **Azure**, **Datasource type** to **Azure Virtual machines**, and **Solution** to **Azure Backup**. Then select **Continue**.
1. Select the Recovery Services vault, select **Continue**, and assign `bp-vm-claims-daily-30d`.
1. Select **Add** under **Virtual Machines**, select `ContosoClaimsApp-VM1`, and then select **OK**.
1. Select **Enable backup**, and wait for the operation to complete.
1. Select **Protected items** in **Resiliency**, filter **Datasource type** to **Azure Virtual machines**, and confirm that the VM appears.
1. Select **More** > **Backup Now** on the VM row, choose a retention date, and then select **OK**.

Monitor the backup under **Resiliency** > **Jobs**. Open the job and confirm that it progresses through these phases:

| Phase | Expected result |
| --- | --- |
| **Snapshot** | Azure Backup captures the VM disks for Instant Restore. |
| **Transfer data to vault** | Azure Backup transfers data for long-term retention. |
| **Validate backup** | Azure Backup verifies that the recovery point is usable. |

> [!IMPORTANT]
> A completed transfer doesn't prove that the recovery point is restorable. Continue only after **Validate backup** succeeds. The initial backup can take more than the estimated exercise time, depending on disk size and data churn. If it remains in progress, record the job ID and continue with the next section.

## Protect the claim documents

Blob protection uses a Backup vault instead of a Recovery Services vault. Configure both operational backup for fast local recovery and vaulted backup for an offsite copy with longer retention.

### Compare Blob backup models

Review how the two protection models address different failure modes before you configure the storage account.

| Capability | Operational backup | Vaulted backup |
| --- | --- | --- |
| Data location | Source storage account | Backup vault |
| Maximum retention | 360 days | 10 years |
| Restore target | Source storage account | Different storage account |
| Schedule | Continuous | Daily or weekly |
| Primary purpose | Recover from accidental blob changes | Retain an isolated, offsite copy |

1. Select both protection models for the lab policy.
1. Choose **30 days** for operational retention.
1. Choose a daily vaulted backup with **30 days** of retention.
1. Record that a production restore from vaulted backup requires a different target storage account.

> [!IMPORTANT]
> Operational backup can't restore a deleted container. In production, enable container soft delete in addition to operational backup, and remove individual blobs instead of deleting an entire container when you need point-in-time recovery.

### Create the Backup vault

The Backup vault manages Blob backup policies and stores vaulted recovery points.

1. Enter **Backup vaults** in the Azure portal search box, and then select **Backup vaults**.
1. Select **Add**.
1. Enter the following values:

    | Setting | Value |
    | --- | --- |
    | **Subscription** | *{lab subscription}* |
    | **Resource group** | *{lab resource group}* |
    | **Backup vault name** | `bv-lab-<unique-id>-<region>` |
    | **Region** | *{same region as the storage account}* |
    | **Storage redundancy** | **Geo-redundant** |

1. Select **Review + create**, and then select **Create**.
1. Open the deployed vault, and confirm that **Storage redundancy** displays **Geo-redundant**.

### Grant access to the storage account

Assign the Backup vault's managed identity the minimum role required to configure protection and apply the Backup-owned delete lock.

1. Open `ContosoClaimsApp-SA1` in the Azure portal.
1. Select **Access control (IAM)** > **Add** > **Add role assignment**.
1. Select **Storage Account Backup Contributor** on the **Role** tab, and then select **Next**.
1. Select **Managed identity** for **Assign access to**, and then select **Select members**.
1. Select **Backup vault**, select `bv-lab-<unique-id>-<region>`, and then select **Select**.
1. Select **Review + assign** twice.
1. Confirm that the role assignment appears under **Role assignments**.

> [!NOTE]
> Role assignment propagation can take up to 30 minutes. If backup readiness validation fails, wait several minutes, and then select **Revalidate**.

### Create the Blob backup policy

Combine operational and vaulted protection in one policy so the storage account has a local recovery path and an offsite copy.

1. Select **Protection policies** > **+ Create Policy** > **Create Backup Policy** in **Resiliency**.
1. Select **Azure Blobs (Azure Storage)** for **Datasource type**, and then select **Continue**.
1. Enter `bp-blob-claims-both-30d` for **Policy name**, select the Backup vault, and then select **Next**.
1. Select **Vaulted backups** and **Operational backups** on **Schedule + retention**.
1. Set vaulted backup to run **Daily** with **30 days** of retention.
1. Set operational backup retention to **30 days**.
1. Select **Review + create**, and then select **Create**.

Confirm that the policy lists both the operational and vaulted data stores.

### Enable and verify Blob protection

Apply the combined policy to the sample container and verify the resulting protection settings.

1. Select **Overview** > **+ Configure protection** in **Resiliency**.
1. Select **Azure Blobs (Azure Storage)** for **Datasource type**, select **Azure Backup** for **Solution**, and then select **Continue**.
1. Select the Backup vault on **Basics**, and then select **Next**.
1. Select `bp-blob-claims-both-30d` on **Backup policy**, and then select **Next**.
1. Select `ContosoClaimsApp-SA1` on **Datasources**. Under **Selected containers**, select **Change** > **Browse containers to backup**, and then select the sample container.
1. Confirm that **Backup readiness** reports success. If it doesn't, select **Revalidate** after the role assignment propagates.
1. Select **Review + configure**, review the settings, and then select **Next** to configure backup.

After the operation completes, open **Resiliency** > **Protected items** and confirm that the storage account appears. Then open the storage account's **Data protection** page and verify that point-in-time restore, blob soft delete, versioning, and change feed are enabled. Under **Settings** > **Locks**, confirm that Azure Backup applied a delete lock.

## Harden the recovery data

Backup data still needs protection from a compromised account that attempts to delete recovery points or reduce retention. Enable reversible immutability in each vault, and assess whether production policy should make it irreversible.

### Enable reversible immutability

Use the policy-based duration so recovery points remain immutable for the retention period defined in their backup policy.

1. Open `rsv-lab-<unique-id>-<region>`.
1. Select **Settings** > **Properties**, and then open the immutable vault settings.
1. Select **Enable based on backup policy**, enable immutability, and save the change.
1. Confirm that the state is **Enabled**, not **Enabled and locked**.
1. Open `bv-lab-<unique-id>-<region>` and repeat the reversible immutability configuration.
1. Confirm that both vaults show **Enabled** and remain unlocked.

> [!IMPORTANT]
> Don't select **Lock immutability**. Locking is irreversible. It enables write once, read many (WORM) enforcement where supported and can prevent you from deleting lab backup data.

### Evaluate the recovery paths

Connect each protected workload to the recovery path that Contoso would use during an incident.

1. Review the available paths:

    | Scenario | VM recovery path | Blob recovery path |
    | --- | --- | --- |
    | Accidental change or deletion | Restore from a vault recovery point. | Restore operational backup to the source account. |
    | Regional disruption | Use Cross Region Restore when the vault configuration supports it. | Restore vaulted backup to a different supported storage account. |
    | Recovery to another subscription | Use Cross Subscription Restore when supported. | Restore to a supported account in the target subscription. |

1. Confirm that the VM vault uses GRS for the planned regional recovery path.
1. Identify a different storage account that could receive a vaulted Blob restore in production.
1. Record which recovery path addresses accidental loss and which addresses a regional disruption.
1. Recommend whether Contoso should lock each vault in production after compliance, cost, retention, and deletion requirements are approved.

## Assess recovery point health

Threat detection uses Microsoft Defender for Cloud signals from the source VM to identify recovery points that might contain malware or ransomware. Enable the preview feature and interpret its status without generating a security incident.

### Enable threat detection

Enable the integration at the Recovery Services vault level so it applies to every protected VM in the vault.

1. Confirm that Defender for Servers Plan 1 or Plan 2 covers `ContosoClaimsApp-VM1`.
1. Open `rsv-lab-<unique-id>-<region>`.
1. Select **Settings** > **Properties**.
1. Open **Security settings**, locate **Threat Detection**, and enable it.
1. Save the vault settings.
1. Confirm that the threat detection setting reports **Enabled**.

### Interpret the assessment

Review the source-scan configuration and recovery point summary to determine whether the available evidence supports a restore decision.

1. Select **Protected items** > **Azure Virtual Machine** in the Recovery Services vault.
1. Open `ContosoClaimsApp-VM1`, and then select **View details**.
1. Confirm that the source-scan configuration shows one of these statuses:

    | Status | Meaning |
    | --- | --- |
    | **Configured** | Defender for Cloud integration is configured. |
    | **Not Configured** | Integration isn't enabled for the protected items. |
    | **Configuration Failed** | Configuration errors prevented integration. |
    | **Not Applicable** | Defender for Servers coverage was downgraded. |

1. Open **Recovery points**, and review the health summary:

    | Result | Recovery decision |
    | --- | --- |
    | **No Threats Reported** | No threat signal was reported for recent recovery points. |
    | **Suspicious RPs found** | Investigate and select an alternative recovery point. |
    | **Not Applicable** | Defender for Servers no longer covers the source VM. |
    | **Unknown (-)** | Treat recovery point health as unproven. |

1. Record the observed status and the recovery point you would investigate first during an incident.
1. Record one residual risk that the configured controls don't address.
1. Propose one production action to reduce that residual risk.

> [!NOTE]
> If a VM has active ransomware alerts when you enable threat detection, the summary can take up to 48 hours to change to **Suspicious**. **No Threats Reported** means that the service didn't report a threat signal. It isn't a guarantee that the recovery point is free from every threat.

## Summary

In this exercise, you protected an Azure VM and Blob Storage data with workload-specific vaults and policies. You validated the VM backup workflow, combined local and offsite Blob protection, enabled reversible immutability, mapped incident scenarios to recovery paths, and interpreted threat detection signals for VM recovery points.

You have successfully completed this exercise.

## Clean up

Remove the protection configuration and vaults that you created. Don't delete the instructor-provisioned VM, storage account, resource group, or Defender for Servers plan.

### Remove Blob protection

1. Open `bv-lab-<unique-id>-<region>`, and disable immutability while the setting is still unlocked.
1. Select **Protected items** in **Resiliency**, and open the Blob backup instance.
1. Select **Stop backup**, choose the option to delete backup data when available, and confirm the operation.
1. Wait for protection removal to complete, and confirm that Azure Backup removes its delete lock from `ContosoClaimsApp-SA1`.
1. Delete `bp-blob-claims-both-30d`.
1. Delete `bv-lab-<unique-id>-<region>`.

### Remove VM protection

1. Open `rsv-lab-<unique-id>-<region>`, and disable immutability while the setting is still unlocked.
1. Select **Protected items** > **Azure Virtual machines** in **Resiliency**, and open `ContosoClaimsApp-VM1`.
1. Select **Stop backup**, select **Delete backup data**, provide the requested confirmation, and confirm the operation.
1. Wait for the backup item to be removed from the vault.
1. Delete `bp-vm-claims-daily-30d` if Azure doesn't remove it with the vault.
1. Delete `rsv-lab-<unique-id>-<region>`.

> [!NOTE]
> Vault deletion can remain blocked while backup items are soft-deleted or operations are in progress. Don't disable subscription-level safety features only to accelerate lab cleanup. Record the vault name and ask the instructor to complete deletion after the retention period when necessary.

## Learn more

Use these resources to review the Azure Backup features that you configured in this exercise:

- [Back up Azure VMs in a Recovery Services vault](/azure/backup/backup-azure-arm-vms-prepare).
- [Configure and manage backup for Azure Blobs](/azure/backup/blob-backup-configure-manage).
- [Use an immutable vault for Azure Backup](/azure/backup/backup-azure-immutable-vault-concept).
- [Understand threat detection for Azure VM backups](/azure/backup/threat-detection-overview).
- [Use an Enhanced policy for Azure VM backup](/azure/backup/backup-azure-vms-enhanced-policy).
