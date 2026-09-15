# Protect Azure data and recover from cyber threats

This 70-minute, portal-based lab uses a fictional insurance claims application to demonstrate data resiliency and cyber recovery with Azure Backup.

Learners protect an Azure VM and Blob Storage data, verify backup configuration, enable reversible vault immutability, map recovery paths, and interpret recovery point threat detection from Microsoft Defender for Cloud.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 4: Protect Azure data and recover from cyber threats](Instructions/Exercises/01-protect-azure-data-and-recover-from-cyber-threats.md) | VM backup, Blob backup, immutable vaults, recovery planning, and threat detection | 70 minutes |

## Lab environment

This portal-based lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- An Azure VM with the Azure VM agent installed and running.
- An Azure storage account with at least one container and sample blobs.
- Contributor access and permission to create vaults, policies, and role assignments.
- Defender for Servers Plan 1 or Plan 2 coverage for the VM.

## Source documentation

- [Back up Azure VMs in a Recovery Services vault](/azure/backup/backup-azure-arm-vms-prepare).
- [Configure and manage backup for Azure Blobs](/azure/backup/blob-backup-configure-manage).
- [Use an immutable vault for Azure Backup](/azure/backup/backup-azure-immutable-vault-concept).
- [Understand threat detection for Azure VM backups](/azure/backup/threat-detection-overview).
- [Original Azure resiliency workshop](https://github.com/Azure/ResiliencyInAzure/blob/main/Labs/DataResiliencyAndCyberRecoveryLab.md).