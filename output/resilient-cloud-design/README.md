# Introduction to resilient cloud design

This 30-minute, portal-based lab introduces resilient cloud design through Caldova's regulated pharmaceutical manufacturing scenario.

Learners translate recovery requirements into an Azure VM backup design, create a Recovery Services vault and retention policy, protect an instructor-provisioned VM, validate a recovery point, and distinguish successful backup from proven application recovery.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 1 - L100: Introduction to resilient cloud design](Instructions/Exercises/01-introduction-to-resilient-cloud-design.md) | Recovery objectives, shared responsibility, VM backup, retention, recovery-point validation, and residual-risk assessment | 30 minutes |

## Lab environment

This portal-based lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- An Azure VM with the Azure VM agent installed and running.
- Contributor access to the lab resource group.
- Permission to create a Recovery Services vault and backup policy.
- The `Microsoft.RecoveryServices` resource provider registered in the subscription.
- Synthetic lab data only. No regulated or customer data is used.

## Workshop alignment

This exercise is Lab 1 in the **Operate with confidence and trust** workshop. It introduces the Start Resilient lifecycle and prepares learners for later labs that assess posture with Infrastructure Resiliency Manager and Azure Advisor, protect additional Azure data, harden recovery data, and evaluate cyber-recovery readiness.

## Source documentation

- [Azure Backup architecture and components](/azure/backup/backup-architecture)
- [Back up Azure VMs in a Recovery Services vault](/azure/backup/backup-azure-arm-vms-prepare)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)
- [Sovereign Landing Zone overview](https://github.com/Azure/sovereign-landing-zone/blob/main/docs/01-Overview.md)
- [Original Azure data resiliency and cyber recovery workshop](https://github.com/Azure/ResiliencyInAzure/blob/main/Labs/DataResiliencyAndCyberRecoveryLab.md)
