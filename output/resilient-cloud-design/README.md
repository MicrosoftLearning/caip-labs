# Resilient cloud design

These portal-based labs introduce resilient cloud design and posture assessment through Caldova's regulated pharmaceutical manufacturing scenario.

Learners translate recovery requirements into an Azure VM backup design, validate a recovery point, establish an Azure Advisor reliability baseline, review recommendations, and prioritize improvements against business requirements.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 1 - L100: Introduction to resilient cloud design](Instructions/Exercises/01-introduction-to-resilient-cloud-design.md) | Recovery objectives, shared responsibility, VM backup, retention, recovery-point validation, and residual-risk assessment | 30 minutes |
| [Lab 2 — L200: Resiliency posture review](Instructions/Exercises/02-resiliency-posture-review.md) | Advisor reliability score, scoped recommendations, business-requirement mapping, residual risks, and improvement prioritization | 35 minutes |

## Lab environment

This portal-based lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- An Azure VM with the Azure VM agent installed and running.
- At least one active Azure Advisor reliability recommendation.
- Contributor access to the lab resource group.
- Permission to create a Recovery Services vault and backup policy.
- The `Microsoft.RecoveryServices` resource provider registered in the subscription.
- Synthetic lab data only. No regulated or customer data is used.

## Workshop alignment

These exercises are Labs 1 and 2 in the **Operate with confidence and trust** workshop. They introduce the Start Resilient lifecycle and prepare learners for later labs that assess application posture with Infrastructure Resiliency Manager, protect additional Azure data, harden recovery data, and evaluate cyber-recovery readiness.

## Source documentation

- [Azure Backup architecture and components](/azure/backup/backup-architecture)
- [Back up Azure VMs in a Recovery Services vault](/azure/backup/backup-azure-arm-vms-prepare)
- [Introduction to Azure Advisor](/azure/advisor/advisor-overview)
- [Advisor score](/azure/advisor/advisor-score)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)
- [Sovereign Landing Zone overview](https://github.com/Azure/sovereign-landing-zone/blob/main/docs/01-Overview.md)
- [Original Azure data resiliency and cyber recovery workshop](https://github.com/Azure/ResiliencyInAzure/blob/main/Labs/DataResiliencyAndCyberRecoveryLab.md)
