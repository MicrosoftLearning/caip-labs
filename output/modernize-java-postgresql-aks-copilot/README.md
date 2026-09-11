# Lab 2: Modernize a Java application and an Oracle application with GitHub Copilot, PostgreSQL, and AKS

This 60-minute lab uses the fictional Caldova inventory and replenishment applications to show how GitHub Copilot supports a bounded Java and Oracle modernization assessment for PostgreSQL and Azure Kubernetes Service (AKS).

Learners inspect a Spring Boot application and extracted Oracle DDL and PL/SQL, identify modernization blockers, externalize database configuration, validate an Oracle-to-PostgreSQL translation and application behavior, review an AKS deployment pattern, and prepare a customer-ready recommendation.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 2: Modernize a Java application and an Oracle application with GitHub Copilot, PostgreSQL, and AKS](Instructions/Exercises/01-modernize-java-postgresql-aks-copilot.md) | Java and Oracle assessment, bounded improvement, Oracle schema translation, PostgreSQL validation, AKS review, and recommendation | 60 minutes |

## Lab files

- `Labfiles/CaldovaInventoryJava` contains the starter Spring Boot application and local PostgreSQL environment.
- `Labfiles/CaldovaInventoryJava/oracle-application` contains extracted Oracle DDL and PL/SQL source artifacts.
- `Labfiles/CaldovaInventoryJava/k8s` contains the prepared AKS workload manifests.
- `Labfiles/CaldovaInventoryJava/evidence` contains assessment and modernization brief templates.
- `Labfiles/CaldovaInventoryJava/solution` contains reference files for the bounded Java improvement and Oracle-to-PostgreSQL translation.

## Source documentation

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [Access and identity in AKS](https://learn.microsoft.com/azure/aks/concepts-identity)
- [Microsoft Entra Workload ID on AKS](https://learn.microsoft.com/azure/aks/workload-identity-overview)
- [Deployment Safeguards in AKS](https://learn.microsoft.com/azure/aks/deployment-safeguards)
- [Scaling options in AKS](https://learn.microsoft.com/azure/aks/concepts-scale)
- [Vector search in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/extensions/how-to-use-pgvector)
- [Read replicas in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/read-replica/concepts-read-replicas)
- [Oracle to Azure Database for PostgreSQL schema conversion](https://learn.microsoft.com/azure/postgresql/migrate/oracle-conversions-schema/schema-conversions-overview)
- [Oracle schema conversion best practices](https://learn.microsoft.com/azure/postgresql/migrate/oracle-conversions-schema/schema-conversions-best-practices)
