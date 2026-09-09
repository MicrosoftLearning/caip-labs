# Caldova workload assessment notes

## Baseline facts

| Area | Verified observation | Evidence file |
| --- | --- | --- |
| Application purpose | _Record the application purpose._ | _Record the file._ |
| API surface | _Record the routes and health endpoint._ | _Record the file._ |
| Java and framework | _Record the Java and Spring Boot versions._ | _Record the file._ |
| Database configuration | _Record where the connection settings are defined._ | _Record the file._ |
| Database access | _Record how reads and writes occur._ | _Record the file._ |
| Container and AKS | _Record the image and Kubernetes assumptions._ | _Record the files._ |

## Prioritized modernization findings

| Rank | Category | Finding and evidence | Risk | Effort | Customer value | Dependency or next action |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | _Category_ | _Finding and cited evidence._ | _Risk_ | _Small, medium, or large_ | _Value_ | _Action_ |
| 2 | _Category_ | _Finding and cited evidence._ | _Risk_ | _Small, medium, or large_ | _Value_ | _Action_ |
| 3 | _Category_ | _Finding and cited evidence._ | _Risk_ | _Small, medium, or large_ | _Value_ | _Action_ |

## Bounded change evidence

| Check | Result | Evidence |
| --- | --- | --- |
| Credential removed from tracked application configuration | _Pass or fail_ | _Describe the reviewed diff._ |
| Missing configuration fails startup | _Pass or fail_ | _Record the missing setting reported._ |
| Updated application packages | _Pass or fail_ | _Record the Maven result._ |
| Health endpoint responds | _Pass or fail_ | _Record the response._ |
| Inventory read succeeds | _Pass or fail_ | _Record returned rows._ |
| Inventory write succeeds | _Pass or fail_ | _Record the created item._ |

## PostgreSQL and AI-readiness checkpoint

| Area | Finding | Required validation or next step |
| --- | --- | --- |
| Schema compatibility | _Record PostgreSQL-specific features and constraints._ | _Action._ |
| Query and connection behavior | _Record pooling, timeout, transaction, or query concerns._ | _Action._ |
| Vector search | _Record whether the current schema supports embeddings._ | _Action._ |
| Workload isolation | _Record how transactional and AI retrieval workloads should be tested or isolated._ | _Action._ |
| Governance | _Record data classification, retention, model-version, or lineage needs._ | _Action._ |

## AKS manifest review

| Control | Status | Evidence and next action |
| --- | --- | --- |
| Versioned image and non-root execution | _Ready, gap, or dependency_ | _Finding._ |
| Configuration and secrets | _Ready, gap, or dependency_ | _Finding._ |
| Workload identity | _Ready, gap, or dependency_ | _Finding._ |
| Probes and resource controls | _Ready, gap, or dependency_ | _Finding._ |
| Scaling and availability | _Ready, gap, or dependency_ | _Finding._ |
| Observability and rollback | _Ready, gap, or dependency_ | _Finding._ |

## Assumptions and discovery questions

- _Record facts that require customer validation, such as service-level objectives, traffic patterns, database size, recovery targets, network restrictions, or downtime tolerance._
