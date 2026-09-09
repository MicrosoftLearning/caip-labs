# Caldova modernization brief

## Executive recommendation

_Summarize the recommended application runtime, SQL target, migration direction, and intended business outcome._

## Top three blockers

1. _Blocker, evidence, and impact._
1. _Blocker, evidence, and impact._
1. _Blocker, evidence, and impact._

## Completed bounded improvement

_Describe the configuration change, why it matters, and the build and smoke-test evidence._

## Application runtime decision

- **Recommended target:** _Azure App Service, Azure Container Apps, or Azure Kubernetes Service._
- **Why it fits:** _Connect verified workload needs to service capabilities._
- **Why not the alternatives:** _Explain why each alternative isn't the first choice for this wave._
- **Dependencies and discovery questions:** _List unresolved requirements._

## SQL Server modernization decision

- **Recommended target:** _Azure SQL Database, Azure SQL Managed Instance, or SQL Server on Azure Virtual Machines._
- **Migration direction:** _Rehost or refactor, followed by an assessment and migration method._
- **Why it fits:** _Connect verified SQL dependencies to target capabilities._
- **Why not the alternatives:** _Explain why each alternative isn't the first choice for this wave._
- **Compatibility and sizing gates:** _List required assessment evidence._

## Security, reliability, and operations

_Describe identity, secret management, network access, availability, observability, backup, and recovery improvements._

## Migration sequence and rollback

1. _Assess compatibility, dependencies, size, performance, and downtime tolerance._
1. _Prepare the application and target environment._
1. _Rehearse migration and validate functional and nonfunctional requirements._
1. _Cut over with monitoring and an agreed rollback trigger._

**Rollback trigger:** _Define a measurable trigger and recovery direction._

## Business value and next wave

_State the customer value in measurable terms where evidence exists, avoid unsupported savings claims, and define the next modernization wave._
