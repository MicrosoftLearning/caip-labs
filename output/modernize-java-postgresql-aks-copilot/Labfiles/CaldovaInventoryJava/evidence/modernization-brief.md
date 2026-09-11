# Caldova Java and Oracle modernization brief

## Executive recommendation

_Summarize the recommended AKS and PostgreSQL target pattern, Oracle migration direction, and intended business outcome._

## Top three blockers

1. _Blocker, evidence, and impact._
1. _Blocker, evidence, and impact._
1. _Blocker, evidence, and impact._

## Completed bounded improvement

_Describe the configuration change, why it matters, and the package and smoke-test evidence._

## Oracle application migration recommendation

- **Source scope:** _Summarize the assessed Oracle tables, constraints, sequence, trigger, package, and function._
- **Conversion decisions:** _Describe direct mappings, redesigns, and behavior that requires validation._
- **Validated translation:** _Record the PostgreSQL execution and representative function results._
- **Migration gates:** _Define live discovery, unsupported-object review, schema conversion, data movement, reconciliation, performance, security, cutover, and rollback checks._
- **Dependencies and discovery questions:** _List unresolved Oracle version, size, feature, workload, and outage requirements._

## AKS deployment recommendation

- **Recommended cluster mode and workload pattern:** _State whether AKS Automatic or AKS Standard fits and describe the workload deployment pattern._
- **Identity and secrets:** _Define Microsoft Entra integration, workload identity, Azure Key Vault, and least-privilege controls._
- **Scaling and availability:** _Define replica, autoscaling, topology, disruption, and service-level considerations._
- **Observability:** _Define logs, metrics, traces, dashboards, alerts, and ownership._
- **Deployment and rollback:** _Define image promotion, rollout validation, rollback trigger, and recovery action._
- **Dependencies and discovery questions:** _List unresolved platform and workload requirements._

## PostgreSQL modernization and AI readiness

- **Recommended target:** _State whether Azure Database for PostgreSQL Flexible Server fits and identify required validation._
- **Connectivity and identity:** _Define private networking, transport security, authentication, secret handling, and connection pooling._
- **Migration gates:** _Define schema compatibility, extension, performance, sizing, high availability, backup, recovery, and cutover checks._
- **AI-ready next step:** _Define a bounded vector-search proof of concept, embedding lifecycle, workload isolation, and governance requirements._
- **Dependencies and discovery questions:** _List unresolved data and operational requirements._

## Migration sequence

1. _Discover the live Oracle estate and assess compatibility, dependencies, traffic, performance, security, and recovery requirements._
1. _Prepare the application image, AKS platform, PostgreSQL target and scratch database, networking, and identities._
1. _Convert and independently validate Oracle objects, move representative data, and resolve review tasks._
1. _Rehearse data migration and application deployment, then reconcile functional and nonfunctional results._
1. _Cut over with monitoring and an agreed rollback trigger._

**Rollback trigger:** _Define a measurable trigger and recovery direction._

## Business value and next wave

_State customer value without unsupported savings claims, identify measurable success indicators, and define the next modernization wave._
