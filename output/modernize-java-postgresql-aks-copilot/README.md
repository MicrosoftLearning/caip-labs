# Modernize Java and PostgreSQL for AKS with GitHub Copilot

This 45-minute lab uses the fictional Caldova inventory application to show how GitHub Copilot supports a bounded Java and PostgreSQL modernization assessment for Azure Kubernetes Service (AKS).

Learners inspect a Spring Boot application backed by PostgreSQL, identify modernization blockers, externalize database configuration, validate read and write behavior, review an AKS deployment pattern, and prepare a customer-ready recommendation.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Modernize a Java and PostgreSQL workload for AKS with GitHub Copilot](Instructions/Exercises/01-modernize-java-postgresql-aks-copilot.md) | Assessment, bounded improvement, database validation, AKS review, and recommendation | 45 minutes |

## Lab files

- `Labfiles/CaldovaInventoryJava` contains the starter Spring Boot application and local PostgreSQL environment.
- `Labfiles/CaldovaInventoryJava/k8s` contains the prepared AKS workload manifests.
- `Labfiles/CaldovaInventoryJava/evidence` contains assessment and modernization brief templates.
- `Labfiles/CaldovaInventoryJava/solution` contains a reference file for the bounded improvement.

## Source documentation

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [Access and identity in AKS](https://learn.microsoft.com/azure/aks/concepts-identity)
- [Microsoft Entra Workload ID on AKS](https://learn.microsoft.com/azure/aks/workload-identity-overview)
- [Deployment Safeguards in AKS](https://learn.microsoft.com/azure/aks/deployment-safeguards)
- [Scaling options in AKS](https://learn.microsoft.com/azure/aks/concepts-scale)
- [Vector search in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/extensions/how-to-use-pgvector)
- [Read replicas in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/read-replica/concepts-read-replicas)
