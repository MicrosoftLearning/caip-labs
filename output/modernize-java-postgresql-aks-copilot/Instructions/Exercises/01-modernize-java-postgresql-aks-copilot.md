---
lab:
    title: 'Modernize a Java and PostgreSQL workload for AKS with GitHub Copilot'
    description: 'Assess a Java workload, make one bounded configuration improvement, validate PostgreSQL behavior, review its AKS target pattern, and prepare a customer-ready recommendation.'
    level: 300
    duration: 45
    islab: true
    primarytopics:
        - GitHub Copilot
        - Java
        - Spring Boot
        - PostgreSQL
        - Azure Kubernetes Service
        - Azure Database for PostgreSQL
---

# Modernize a Java and PostgreSQL workload for AKS with GitHub Copilot

Caldova operates a Java inventory application backed by PostgreSQL. The application works locally, but its database credential is stored in source control, and its cloud deployment assumptions require validation. Caldova wants to prepare the workload for cloud-native operations on Azure Kubernetes Service (AKS) and establish an AI-ready data direction.

In this exercise, you act as part of the Microsoft technical team. You use GitHub Copilot to assess the Spring Boot codebase, externalize database configuration, validate PostgreSQL read and write behavior, review a prepared AKS workload pattern, and create an evidence-based customer recommendation. Copilot accelerates the work, but you remain responsible for validating its claims and edits.

This exercise should take approximately **45** minutes to complete.

## Prerequisites

To complete this exercise, you need:

- [Visual Studio Code](https://code.visualstudio.com/) installed.
- Access to [GitHub Copilot](https://docs.github.com/copilot/get-started/what-is-github-copilot) with chat enabled, and a GitHub account signed in to Visual Studio Code.
- A [Java Development Kit (JDK) 21](https://learn.microsoft.com/java/openjdk/download) distribution installed.
- [Apache Maven 3.9](https://maven.apache.org/download.cgi) or later installed.
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running with Linux containers enabled.
- The files in this lab's `Labfiles/CaldovaInventoryJava` folder.

To review the prepared Kubernetes manifests, install [`kubectl`](https://kubernetes.io/docs/tasks/tools/). To use the optional AKS deployment path, you also need the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), an Azure subscription, access to a prepared AKS cluster, and a versioned application image in a registry that the cluster can pull from.

To keep the timed exercise to 45 minutes, download the `postgres:16.10` container image and Maven dependencies before the session.

> [!IMPORTANT]
> The password in the starter files is a synthetic local-development credential. Never submit real credentials, customer code, customer data, or confidential information to a prompt unless your organization's policies permit it.

## Establish the application baseline

Start PostgreSQL and inspect the application before asking Copilot to recommend changes. This baseline separates observed facts from generated suggestions.

> [!TIP]
> Timebox this section to five minutes.

### Start PostgreSQL and package the application

1. Open Visual Studio Code, and then open the `Labfiles/CaldovaInventoryJava` folder.
1. Open the integrated terminal by selecting **Terminal** > **New Terminal**.
1. Confirm the required tools by running:

    ```powershell
    java -version
    mvn -version
    docker version
    ```

    Confirm that Java 21, Maven 3.9 or later, and the Docker server are available.

1. Remove any environment left by an earlier lab run by running:

    ```powershell
    docker compose down --volumes
    ```

    This command makes the three-row baseline deterministic by removing the previous local database volume.

1. Start PostgreSQL by running:

    ```powershell
    docker compose up -d
    ```

    The command starts PostgreSQL on local port `5433` and initializes three inventory rows.

1. Confirm that the container is healthy by running:

    ```powershell
    docker compose ps
    ```

    Confirm that the `caldova-postgres` container displays `healthy` in the **STATUS** column.

1. Package the application by running:

    ```powershell
    mvn clean package
    ```

    Confirm that Maven reports `BUILD SUCCESS`.

### Verify the baseline

Run the application and verify its health and database read path before changing it.

1. Start the application by running:

    ```powershell
    mvn spring-boot:run
    ```

    Wait until the terminal reports that the application started on port `8080`.

1. Open a second integrated terminal by selecting **Terminal** > **New Terminal**.
1. Verify application and database health by running:

    ```powershell
    Invoke-RestMethod http://localhost:8080/actuator/health
    ```

    Confirm that the response status is `UP`.

1. Verify the inventory read path by running:

    ```powershell
    Invoke-RestMethod http://localhost:8080/inventory | Format-Table
    ```

    Confirm that the response lists three Caldova inventory items.

1. Return to the application terminal, and press **Ctrl+C** to stop the application.
1. Open `pom.xml`, `src/main/resources/application.properties`, `InventoryController.java`, `InventoryRepository.java`, `Dockerfile`, `compose.yaml`, `scripts/init.sql`, and `k8s/caldova-inventory.yaml`. Record these facts in `evidence/assessment-notes.md`:

    - The application purpose and API surface.
    - The Java and Spring Boot versions.
    - The location of the PostgreSQL connection settings.
    - The query and write patterns.
    - The local container and prepared AKS assumptions.

You now have a working baseline and evidence you can use to verify Copilot's assessment.

## Assess the workload with GitHub Copilot

Use Ask mode to identify Java, PostgreSQL, container, and AKS modernization concerns without changing files. Treat each response as a hypothesis until the repository supports it.

> [!TIP]
> Timebox this section to 10 minutes. Record the three most important verified findings instead of every possible backlog item.

1. Select the **Chat** icon in Visual Studio Code, and select **Ask** from the mode picker.
1. Enter this architecture assessment prompt:

    ```prompt
    Analyze this workspace as a Java, PostgreSQL, and AKS modernization architect.
    Summarize the application architecture, request and data flow, Java and Spring
    Boot versions, Maven dependencies, PostgreSQL touchpoints, connection handling,
    schema assumptions, container readiness, and AKS deployment assumptions. Cite
    the workspace file that supports each claim. Do not edit files. Mark anything
    you cannot verify as an assumption or discovery question.
    ```

    Copilot should cite source and configuration files and separate facts from assumptions.

1. Review every cited file, and correct any unsupported claim.
1. Enter this prioritization prompt:

    ```prompt
    From verified workspace evidence, identify modernization findings for the Java
    application, PostgreSQL database, container image, and AKS pattern. Group each
    finding as security, compatibility, reliability, operations, performance, or
    maintainability. For each finding, provide evidence, risk, effort (small,
    medium, or large), customer value, deployment dependency, and a safe next
    action. Rank the top three blockers. Do not edit files or invent customer facts.
    ```

1. Copy the three verified blockers and their evidence into `evidence/assessment-notes.md`.
1. Confirm that the findings address the source-controlled credential and any material gaps in identity, secrets, observability, rollback, or database migration validation. Add a missed concern only when the files support it.
1. Save the evidence file by pressing **Ctrl+S**.

The assessment now connects repository evidence to modernization risk, effort, customer value, and deployment dependencies.

## Externalize the PostgreSQL configuration

Make one bounded improvement by replacing the source-controlled database values with required environment placeholders. This change preserves data access while preparing the application for environment-specific configuration and a managed secret source.

> [!TIP]
> Timebox this section to 13 minutes. If Copilot doesn't produce a bounded change after one correction, use the reference file in `solution` and continue to validation.

### Generate and review the change

1. Select **Agent** from the Copilot Chat mode picker.
1. Enter this implementation prompt:

    ```prompt
    Make one bounded configuration change in this Spring Boot application.

    Acceptance criteria:
    - Edit only src/main/resources/application.properties.
    - Replace the hard-coded datasource URL, username, and password with required
      environment placeholders named CALDOVA_DB_URL, CALDOVA_DB_USERNAME, and
      CALDOVA_DB_PASSWORD.
    - Do not provide fallback values, because a missing setting must fail startup.
    - Keep all other settings unchanged.
    - Do not edit Java, Maven, Docker, Compose, SQL, Kubernetes, or evidence files.
    - Run mvn clean package after the edit and summarize the exact change.

    Ask before making a change outside the allowed file.
    ```

1. Review the proposed edit. Confirm that the three datasource values use `${CALDOVA_DB_URL}`, `${CALDOVA_DB_USERNAME}`, and `${CALDOVA_DB_PASSWORD}` without defaults.
1. Reject any edit that changes Java code, dependencies, API routes, database logic, or deployment files. Restate the boundary if needed.
1. Save the file by pressing **Ctrl+S**.
1. Compare the result with the supplied reference by running:

    ```powershell
    code --diff solution/application.properties src/main/resources/application.properties
    ```

    Confirm that the files differ only in comments or other changes that still meet the acceptance criteria. Close the comparison editor when you finish.

### Validate the configuration boundary

Verify that the application fails clearly without deployment configuration, then provide local values through the environment.

1. Clear any existing settings and start the application by running:

    ```powershell
    Remove-Item Env:CALDOVA_DB_URL,Env:CALDOVA_DB_USERNAME,Env:CALDOVA_DB_PASSWORD -ErrorAction SilentlyContinue
    mvn spring-boot:run
    ```

    Confirm that startup fails and identifies an unresolved `CALDOVA_DB_` setting. This failure prevents an accidental deployment with implicit credentials.

1. Set the synthetic local values in the same terminal by running:

    ```powershell
    $env:CALDOVA_DB_URL = "jdbc:postgresql://localhost:5433/caldova_inventory"
    $env:CALDOVA_DB_USERNAME = "caldova"
    $env:CALDOVA_DB_PASSWORD = "Caldova_Local_2026!"
    ```

    These values exist only in the current PowerShell process. A production deployment should retrieve sensitive values from an approved secret store rather than commit them to a manifest.

1. Package the updated application by running:

    ```powershell
    mvn clean package
    ```

    Confirm that Maven reports `BUILD SUCCESS` before you continue.

1. Record the missing-configuration result, reviewed diff, and package result in `evidence/assessment-notes.md`.

The bounded change removes the database credential from tracked Spring configuration without redesigning the application.

## Validate PostgreSQL behavior and AI readiness

Run a smoke test for health, read, and write behavior. Then use database evidence to define an AI-readiness next step without claiming that the current schema already supports vector search.

> [!TIP]
> Timebox this section to eight minutes.

### Test application and database behavior

1. Start the updated application by running:

    ```powershell
    mvn spring-boot:run
    ```

1. Open a second integrated terminal and verify the health endpoint by running:

    ```powershell
    Invoke-RestMethod http://localhost:8080/actuator/health
    ```

    Confirm that the status is `UP`.

1. Verify the database read path by running:

    ```powershell
    Invoke-RestMethod http://localhost:8080/inventory | Format-Table
    ```

1. Verify the database write path by running:

    ```powershell
    $body = @{ sku = "CAL-400"; name = "Field sensor"; quantity = 18 } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri http://localhost:8080/inventory -ContentType "application/json" -Body $body
    ```

    Confirm that the response includes `CAL-400` and an assigned numeric `id`.

1. Inspect the PostgreSQL version, schema, and indexes by running:

    ```powershell
    docker compose exec postgres psql -U caldova -d caldova_inventory -c "SELECT version();"
    docker compose exec postgres psql -U caldova -d caldova_inventory -c "\d+ inventory_items"
    ```

1. Return to the application terminal, and press **Ctrl+C** to stop the application.

### Define an AI-ready data checkpoint

1. Select **Ask** in Copilot Chat, and enter this data review prompt:

    ```prompt
    Review scripts/init.sql, InventoryRepository.java, application.properties,
    and the observed PostgreSQL read and write results. Produce a concise Azure
    Database for PostgreSQL Flexible Server readiness checkpoint covering schema
    compatibility, connection pooling and timeouts, query and index validation,
    migration rehearsal, high availability, backup and recovery, and private
    connectivity. Then define a bounded vector-search proof of concept. Include
    extension allowlisting, CREATE EXTENSION vector, a separate embedding table,
    source-record identity, embedding model and version metadata, re-embedding,
    index and recall testing, workload isolation, access control, retention, and
    lineage. Do not claim that embeddings or pgvector exist in this repository.
    Mark customer-specific requirements as discovery questions.
    ```

1. Validate these generated claims against current guidance:

    - Azure Database for PostgreSQL requires the `vector` extension to be added to the server allowlist before `CREATE EXTENSION vector` runs in a database.
    - Read replicas can isolate eligible read-heavy workloads, but replication is asynchronous and requires lag monitoring.
    - A vector proof of concept requires representative data, retrieval-quality measures, performance tests, and governance decisions before production use.

1. Record the verified findings and next steps in the **PostgreSQL and AI-readiness checkpoint** table in `evidence/assessment-notes.md`. Save the file by pressing **Ctrl+S**.

The evidence confirms the core transaction path and defines AI readiness as a measured next step, not an assumed capability.

## Review the AKS deployment pattern

Review the prepared workload manifests for identity, configuration, secrets, scaling, observability, and rollback. The standard path is a design review. Use the optional deployment steps only when a prepared AKS environment and image are available.

> [!TIP]
> Timebox this section to seven minutes.

### Validate and assess the manifests

1. Run a client-side syntax check against the prepared manifest:

    ```powershell
    kubectl apply --dry-run=client --validate=false -f k8s/caldova-inventory.yaml
    ```

    Confirm that the output lists the namespace, service account, configuration, deployment, service, and autoscaler.

1. Select **Ask** in Copilot Chat, and enter this review prompt:

    ```prompt
    Review Dockerfile and k8s/caldova-inventory.yaml as a production AKS workload
    proposal. Do not edit files. Identify what is implemented, what is a placeholder,
    and what is missing. Cover AKS Automatic versus Standard, versioned images,
    registry access, non-root execution, Pod Security Standards, resource requests
    and limits, probes, availability, HPA dependencies, topology, network policy,
    ingress, Microsoft Entra Workload ID, Key Vault integration, PostgreSQL private
    connectivity, observability, deployment safeguards, image promotion, rollout
    validation, and rollback. Rank gaps as blocker, preproduction, or later wave,
    cite file evidence, and identify customer discovery questions.
    ```

1. Verify that the response recognizes these boundaries:

    - The manifest labels the pod for Microsoft Entra Workload ID, but placeholders and a federated identity still require configuration.
    - The password references a Kubernetes secret, but the repository doesn't create or populate that secret. The target design must define an approved source, such as Azure Key Vault integration, or replace password authentication with a validated identity-based database pattern.
    - Probes, resources, two replicas, topology spread, a rolling update, and an HPA are present, but production thresholds require load and failure testing.
    - Observability, network policy, disruption controls, ingress, image promotion, and measurable rollback criteria remain design decisions.

1. Record the verified controls, gaps, and next actions in the **AKS manifest review** table in `evidence/assessment-notes.md`.

### Deploy to a prepared AKS target

Skip this subsection unless the facilitator provides a cluster, a pullable image, and deployment-specific values.

1. Sign in to Azure and select the supplied subscription by running:

    ```powershell
    az login
    az account set --subscription "REPLACE_WITH_SUBSCRIPTION_ID"
    ```

1. Get credentials for the prepared cluster by running:

    ```powershell
    az aks get-credentials --resource-group "REPLACE_WITH_RESOURCE_GROUP" --name "REPLACE_WITH_CLUSTER_NAME" --overwrite-existing
    ```

1. Replace every `REPLACE_WITH_` value in `k8s/caldova-inventory.yaml`, and arrange the approved database credential or identity configuration. Save the manifest by pressing **Ctrl+S**.
1. Apply and monitor the workload by running:

    ```powershell
    kubectl apply -f k8s/caldova-inventory.yaml
    kubectl rollout status deployment/caldova-inventory -n caldova --timeout=180s
    kubectl get pods,service,hpa -n caldova
    ```

1. Record pod readiness, rollout status, and any safeguard warnings. If rollout validation fails, return to the previous revision by running:

    ```powershell
    kubectl rollout undo deployment/caldova-inventory -n caldova
    ```

The AKS review now distinguishes controls already represented in the manifests from platform dependencies and production validation gates.

## Prepare the customer recommendation

Convert the verified evidence into a concise modernization recommendation. Keep unknown customer requirements as discovery questions.

> [!TIP]
> Timebox this section to two minutes by using the supplied brief template.

1. Attach `evidence/assessment-notes.md` and `evidence/modernization-brief.md` to Copilot Chat, and enter:

    ```prompt
    Complete the Caldova Java modernization brief from the verified assessment
    notes and template. Include the top three blockers; the completed bounded
    change and validation; an AKS deployment pattern with identity, secrets,
    scaling, observability, and rollback controls; an Azure Database for PostgreSQL
    modernization direction; one bounded AI-readiness next step; dependencies;
    customer value; success measures; and the next modernization wave. Distinguish
    AKS Automatic from AKS Standard based on documented requirements. Do not invent
    workload facts, timelines, savings, or service-level objectives. Label missing
    customer information as discovery questions.
    ```

1. Review the draft against the evidence, remove unsupported claims, and save `evidence/modernization-brief.md` by pressing **Ctrl+S**.
1. Confirm that the brief contains all five deliverables:

    - The top three modernization blockers.
    - One completed or reviewed Java, PostgreSQL, container, or AKS improvement.
    - A recommended AKS deployment pattern and key operational controls.
    - A recommended PostgreSQL modernization and AI-readiness next step.
    - A business-value statement and next modernization wave.

## Summary

In this exercise, you used GitHub Copilot to assess a Java and PostgreSQL workload, externalize its database configuration, validate its core transaction path, review an AKS deployment pattern, and prepare an evidence-based customer recommendation.

You have successfully completed this exercise.

## Clean up

Remove the local PostgreSQL environment and any optional AKS workload after you finish the exercise.

1. Open an integrated terminal in the `Labfiles/CaldovaInventoryJava` folder.
1. Stop PostgreSQL and delete its local data by running:

    ```powershell
    docker compose down --volumes
    ```

1. Clear the local database settings by running:

    ```powershell
    Remove-Item Env:CALDOVA_DB_URL,Env:CALDOVA_DB_USERNAME,Env:CALDOVA_DB_PASSWORD -ErrorAction SilentlyContinue
    ```

1. Remove the exercise namespace if you used the optional AKS path by running:

    ```powershell
    kubectl delete namespace caldova
    ```

1. Confirm that the local container is removed by running:

    ```powershell
    docker compose ps
    ```

## Additional resources

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [Access and identity in AKS](https://learn.microsoft.com/azure/aks/concepts-identity)
- [Microsoft Entra Workload ID on AKS](https://learn.microsoft.com/azure/aks/workload-identity-overview)
- [Azure Key Vault Provider for Secrets Store CSI Driver](https://learn.microsoft.com/azure/aks/csi-secrets-store-driver)
- [Deployment Safeguards in AKS](https://learn.microsoft.com/azure/aks/deployment-safeguards)
- [Scaling options in AKS](https://learn.microsoft.com/azure/aks/concepts-scale)
- [Allow extensions in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/extensions/how-to-allow-extensions)
- [Vector search in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/extensions/how-to-use-pgvector)
- [Read replicas in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/read-replica/concepts-read-replicas)
