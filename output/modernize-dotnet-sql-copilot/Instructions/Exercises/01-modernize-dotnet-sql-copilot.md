---
lab:
    title: 'Modernize a .NET and SQL Server workload with GitHub Copilot'
    description: 'Assess a legacy workload, make one bounded configuration improvement, validate the result, and prepare an Azure modernization recommendation.'
    level: 300
    duration: 45
    islab: true
    primarytopics:
        - GitHub Copilot
        - .NET
        - SQL Server
        - Azure application modernization
        - Azure SQL
---

# Modernize a .NET and SQL Server workload with GitHub Copilot

Caldova operates a business-critical ASP.NET Core inventory application backed by SQL Server. The application works, but it has technical debt, manual deployment assumptions, a framework dependency, and a database credential embedded in source code. You act as part of the Microsoft technical team preparing a focused modernization recommendation.

In this exercise, you use GitHub Copilot to assess the workload, externalize the database connection string, verify inventory read and write operations, and recommend an Azure application runtime and SQL modernization target. Copilot accelerates the analysis and implementation, but you remain responsible for reviewing its claims and changes.

This exercise should take approximately **45** minutes to complete.

## Prerequisites

To complete this exercise, you need:

- [Visual Studio Code](https://code.visualstudio.com/) installed.
- Access to [GitHub Copilot](https://docs.github.com/copilot/get-started/what-is-github-copilot) with chat enabled, and a GitHub account signed in to Visual Studio Code.
- The [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) installed.
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running with Linux containers enabled.
- [Git](https://git-scm.com/downloads) installed.
- The files in this lab's `Labfiles/CaldovaInventory` folder.

To keep the timed exercise to 45 minutes, download the `mcr.microsoft.com/mssql/server:2022-latest` container image before the session. The SQL Server Linux container requires an x86-64 host. Use a prepared x86-64 lab environment if your device has an Arm processor.

> [!IMPORTANT]
> The password in the starter files is a synthetic local-development credential. Never submit real credentials, customer code, customer data, or confidential information to a prompt unless your organization's policies permit it.

## Establish the application baseline

Start the local SQL Server container and inspect the application before asking Copilot to recommend changes. This baseline separates observed facts from AI-generated suggestions.

> [!TIP]
> Timebox this section to five minutes. The container image should already be available in the lab environment.

### Start the database

1. Open Visual Studio Code, and then open the `Labfiles/CaldovaInventory` folder.
1. Open the integrated terminal by selecting **Terminal** > **New Terminal**.
1. Start SQL Server by running the following command:

    ```powershell
    docker compose up -d
    ```

    The command starts a local SQL Server 2022 container on port `14333`.

1. Wait until the container reports that it is healthy by running:

    ```powershell
    docker compose ps
    ```

    Confirm that the `caldova-sql` service displays `healthy` in the **STATUS** column.

1. Create and seed the sample database by running:

    ```powershell
    docker compose exec sql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Caldova_Local_2026!" -C -b -i /scripts/init.sql
    ```

    The script creates `CaldovaInventory`, adds an `InventoryItems` table, and inserts three sample rows. A message reports that initialization is complete.

1. Build the application by running:

    ```powershell
    dotnet build
    ```

    Confirm that the build succeeds with no errors.

### Verify current behavior

Run the API before changing it to establish a functional baseline.

1. Start the application by running:

    ```powershell
    Remove-Item Env:ConnectionStrings__Inventory -ErrorAction SilentlyContinue
    dotnet run
    ```

1. Open a second integrated terminal by selecting **Terminal** > **New Terminal**.
1. Verify the health and database read paths by running:

    ```powershell
    Invoke-RestMethod http://localhost:5050/health
    Invoke-RestMethod http://localhost:5050/inventory | Format-Table
    ```

    Confirm that the health response includes `Healthy` and the inventory response contains three rows.

1. Return to the application terminal, and press **Ctrl+C** to stop the application.

1. Open `Program.cs`, `Data/InventoryRepository.cs`, `Caldova.Inventory.Api.csproj`, `compose.yaml`, and `scripts/init.sql`. Record the following facts in `evidence/assessment-notes.md`:

    - The application's purpose and exposed endpoints.
    - The target .NET framework.
    - Where the database connection string is defined.
    - How the application reads and writes inventory data.
    - How the local database is initialized.

You now have a fact-based baseline and a working local database.

## Assess the workload with GitHub Copilot

Use Copilot Ask mode to identify application and SQL Server modernization concerns without changing files. Treat the response as a hypothesis that requires verification against the repository.

> [!TIP]
> Timebox this section to 10 minutes. Record the three most important verified findings rather than every possible backlog item.

1. Select the **Chat** icon in Visual Studio Code, and select **Ask** from the mode picker.
1. Enter the following prompt to summarize the workload:

    ```prompt
    Analyze this workspace as a .NET and SQL Server modernization architect.
    Summarize the application architecture, request flow, framework and package
    dependencies, SQL Server touchpoints, configuration sources, deployment
    assumptions, and runtime constraints. Cite the file that supports each claim.
    Do not edit files. Mark anything you cannot verify as an assumption.
    ```

    Copilot should describe the minimal API, repository, SQL container, configuration, and target framework. It should distinguish evidence from assumptions.

1. Review Copilot's cited files, and correct any claim that isn't supported by the code.
1. Review the [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core), and record that .NET 8 reaches end of support on November 10, 2026. Treat assessment of an upgrade to the current .NET 10 long-term support release as a blocker because Caldova needs a supported production runtime.
1. Enter the following prompt to prioritize findings:

    ```prompt
    Based on evidence in this workspace and the verified .NET support-policy fact
    that .NET 8 reaches end of support on November 10, 2026, identify modernization
    findings for the application and database. Group them as security, compatibility,
    reliability, operations, or maintainability. For each finding, provide the
    evidence, risk, effort (small, medium, or large), customer value, and a safe
    next action. Rank the top three blockers. Do not edit files.
    ```

1. Copy the verified top three blockers and supporting evidence into `evidence/assessment-notes.md`. Save the file by pressing **Ctrl+S**.
1. Confirm that the prioritized list includes the source-controlled SQL credential and framework lifecycle. Add any missed database compatibility or migration validation concern.

The assessment now connects code evidence to modernization risk, effort, and customer value.

## Externalize the database configuration

Make one bounded improvement: remove the local SQL Server connection string from C# source and load it through .NET configuration. This change prepares the application for environment-specific settings and later use of managed identity without changing its data-access behavior.

> [!TIP]
> Timebox this section to 15 minutes. If Copilot doesn't produce a bounded change after one correction, use the files in `solution` and continue to validation.

### Generate and review the change

1. Select **Agent** from the Copilot Chat mode picker.
1. Enter the following implementation prompt:

    ```prompt
    Make one bounded configuration change in this ASP.NET Core application.

    Acceptance criteria:
    - Remove the hard-coded SQL connection string from Program.cs.
    - Read ConnectionStrings:Inventory through ASP.NET Core configuration.
    - Fail at startup with a clear message when the value is missing, empty, or whitespace.
    - Add an empty Inventory entry to appsettings.json. Do not put a password there.
    - Keep InventoryRepository and every API route unchanged.
    - Do not add packages, redesign data access, or change compose.yaml.
    - Build the project after editing and summarize the exact files changed.

    Ask before making any change outside Program.cs and appsettings.json.
    ```

1. Review the edits in the chat changes list. Confirm that `Program.cs` uses `builder.Configuration.GetConnectionString("Inventory")`, rejects a blank value, and doesn't contain the password.
1. Confirm that `appsettings.json` contains an empty `Inventory` connection-string entry and no credential.
1. Retain the edits only when they satisfy every acceptance criterion. If Copilot changes routes, packages, repository logic, or container settings, discard those edits and restate the boundary.
1. Save all changed files by selecting **File** > **Save All**.

### Configure and inspect the application

Supply local configuration through an environment variable, then build and compare the bounded change.

1. Verify the missing-configuration guard by running:

    ```powershell
    Remove-Item Env:ConnectionStrings__Inventory -ErrorAction SilentlyContinue
    dotnet run
    ```

    Confirm that startup stops with a message that identifies the missing `Inventory` connection string. If the application starts or reports only a SQL client error, correct the blank-value check before continuing.

1. Configure the connection string for the current PowerShell terminal by running:

    ```powershell
    $env:ConnectionStrings__Inventory = "Server=localhost,14333;Database=CaldovaInventory;User Id=sa;Password=Caldova_Local_2026!;Encrypt=True;TrustServerCertificate=True"
    ```

    The double underscore maps the environment variable to the .NET configuration key `ConnectionStrings:Inventory`. In production, use managed identity where the selected Azure SQL target supports it instead of storing a password.

1. Build the updated application by running:

    ```powershell
    dotnet build
    ```

1. Compare the updated files with the supplied reference by running:

    ```powershell
    code --diff solution/Program.cs Program.cs
    code --diff solution/appsettings.json appsettings.json
    ```

    Confirm that the files differ only in formatting or other changes that still meet the acceptance criteria. Close both comparison editors when you finish.

The application now receives environment-specific database configuration without embedding a credential in C# source.

## Validate the change and collect evidence

Run the application and verify the health and inventory read behavior observed in the baseline, then test the write path. This smoke test provides functional evidence, but it isn't a substitute for performance, security, and migration testing.

> [!TIP]
> Timebox this section to eight minutes.

### Test the API

1. Start the application by running:

    ```powershell
    dotnet run
    ```

    Wait until the terminal reports that the application is listening on `http://localhost:5050`.

1. Open a second integrated terminal by selecting **Terminal** > **New Terminal**.
1. Verify the health endpoint by running:

    ```powershell
    Invoke-RestMethod http://localhost:5050/health
    ```

    Confirm that the response includes `Healthy`.

1. Verify the database read path by running:

    ```powershell
    Invoke-RestMethod http://localhost:5050/inventory | Format-Table
    ```

    Confirm that the response lists three Caldova inventory items.

1. Verify the database write path by running:

    ```powershell
    $body = @{ sku = "CAL-400"; name = "Field sensor"; quantity = 18 } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri http://localhost:5050/inventory -ContentType "application/json" -Body $body
    ```

    Confirm that the response includes `CAL-400` and an assigned numeric `id`.

1. Repeat the read request to confirm that the new item is returned:

    ```powershell
    Invoke-RestMethod http://localhost:5050/inventory | Format-Table
    ```

### Record the evidence

Capture enough evidence to support the recommendation, and then stop the local application.

1. Record the build result, health result, read result, write result, and reviewed file diff in `evidence/assessment-notes.md`. Save the file by pressing **Ctrl+S**.
1. Return to the application terminal, and press **Ctrl+C** to stop the application.

The collected evidence shows that the bounded configuration change preserves the application's core database behavior.

## Prepare the modernization recommendation

Select target services based on verified workload requirements rather than selecting technology from preference. Copilot helps draft the brief, but your evidence and customer constraints determine the recommendation.

> [!TIP]
> Timebox this section to seven minutes. Keep the brief concise and mark missing customer facts as discovery questions.

1. Review these application-runtime decision points:

    | Runtime | Favor when | Validate before selection |
    | --- | --- | --- |
    | Azure App Service | The workload is an HTTP web app or API and doesn't require Kubernetes orchestration | Runtime support, networking, scaling, deployment slots, and operating-system dependencies |
    | Azure Container Apps | The team wants containers, revisions, event-driven scaling, or scale to zero without managing Kubernetes | Container readiness, ingress, background processing, networking, and scaling behavior |
    | Azure Kubernetes Service (AKS) | A platform team requires Kubernetes APIs, cluster-level control, complex orchestration, or an existing Kubernetes operating model | Whether AKS Automatic or Standard fits, platform skills, governance, cluster operations, cost, and whether the added control is necessary |

1. Review these SQL target decision points:

    | Target | Favor when | Validate before selection |
    | --- | --- | --- |
    | Azure SQL Database | The application can remove instance-scoped dependencies and use a managed database suited to modern cloud applications | Feature compatibility, database size, performance, connectivity, downtime, and replacement of SQL Agent or cross-database dependencies |
    | Azure SQL Managed Instance | The workload needs high SQL Server compatibility, instance-scoped features, native virtual network integration, or a lower-change migration | Feature differences, sizing, networking, migration method, provisioning lead time, and cost |
    | SQL Server on Azure Virtual Machines | The workload requires operating-system access, a fixed SQL Server version, or unsupported platform-as-a-service features | Infrastructure operations, patching, backups, availability, licensing, and later modernization waves |

1. Select **Ask** in Copilot Chat, attach `evidence/assessment-notes.md` and `evidence/modernization-brief.md`, and enter:

    ```prompt
    Draft the modernization brief from the verified assessment notes and the
    template. Recommend one application runtime from Azure App Service, Azure
    Container Apps, or AKS. Recommend one database direction from Azure SQL
    Database, Azure SQL Managed Instance, or SQL Server on Azure Virtual Machines.
    Explain why each alternative is not the current first choice. Include the top
    three blockers, the completed bounded change, dependencies, security and
    identity improvements, migration sequence, validation gates, rollback trigger,
    business value, and the next modernization wave. Do not invent workload facts.
    Label missing customer information as a discovery question.
    ```

1. Review the draft against your evidence and the linked Microsoft documentation. Remove unsupported claims and record unanswered discovery questions.
1. Save the completed `evidence/modernization-brief.md` by pressing **Ctrl+S**.
1. Confirm that the brief contains all five required deliverables:

    - The top three modernization blockers.
    - The completed configuration improvement and validation evidence.
    - One recommended Azure application runtime.
    - One recommended SQL Server modernization target and migration direction.
    - A business-value statement and next modernization wave.

## Summary

In this exercise, you used GitHub Copilot to assess a .NET and SQL Server workload, verify findings against source files, externalize a database connection string, validate read and write behavior, and prepare an evidence-based Azure modernization recommendation.

You have successfully completed this exercise.

## Clean up

Remove the local SQL Server container, network, and database volume after you finish the exercise.

1. Open an integrated terminal in the `Labfiles/CaldovaInventory` folder.
1. Stop the environment and delete its local data by running:

    ```powershell
    docker compose down --volumes
    ```

1. Clear the connection string from the current PowerShell session by running:

    ```powershell
    Remove-Item Env:ConnectionStrings__Inventory -ErrorAction SilentlyContinue
    ```

1. Confirm that the container is removed by running:

    ```powershell
    docker compose ps
    ```

## Additional resources

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [Choose an Azure compute service](https://learn.microsoft.com/azure/architecture/guide/technology-choices/compute-decision-tree)
- [Azure App Service overview](https://learn.microsoft.com/azure/app-service/overview)
- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Kubernetes Service overview](https://learn.microsoft.com/azure/aks/what-is-aks)
- [SQL Server to Azure SQL Database migration overview](https://learn.microsoft.com/data-migration/sql-server/database/overview)
- [Compare Azure SQL Database and Azure SQL Managed Instance features](https://learn.microsoft.com/azure/azure-sql/database/features-comparison)
