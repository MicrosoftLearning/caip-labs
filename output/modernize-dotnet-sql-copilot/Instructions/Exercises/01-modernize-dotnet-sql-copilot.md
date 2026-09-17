---
lab:
    title: 'Lab 1: Modernize a .NET application and SQL Server database with GitHub Copilot and CLI'
    description: 'Use GitHub Copilot in Visual Studio Code and from the command line to assess a legacy workload, improve its configuration, migrate its database to Azure SQL Database, and deploy the application to Azure Container Apps.'
    level: 300
    duration: 60
    islab: true
    primarytopics:
        - GitHub Copilot
        - GitHub Copilot CLI
        - .NET
        - SQL Server
        - Azure application modernization
        - Azure SQL
---

# Lab 1: Modernize a .NET application and SQL Server database with GitHub Copilot and CLI

Caldova operates a business-critical ASP.NET Core inventory application backed by SQL Server. The application works, but it has technical debt, manual deployment assumptions, a framework dependency, and a database credential embedded in source code. You act as part of the Microsoft technical team migrating the workload to Azure.

In this exercise, you use GitHub Copilot in Visual Studio Code to assess and update the workload. You use GitHub Copilot CLI to review the bounded change and its container readiness. You then migrate the sample data to Azure SQL Database, build the container image in Azure, deploy it to Azure Container Apps, and validate the public API. Copilot accelerates the work, but you remain responsible for reviewing its commands, claims, and changes.

This exercise should take approximately **60** minutes to complete.

## Prerequisites

To complete this exercise, you need:

- [Visual Studio Code](https://code.visualstudio.com/) installed.
- Access to [GitHub Copilot](https://docs.github.com/copilot/get-started/what-is-github-copilot) with chat enabled, and a GitHub account signed in to Visual Studio Code.
- Access to GitHub Copilot CLI through your GitHub Copilot plan and organization policies.
- An Azure subscription where you have permission to create resources and role assignments. The **Owner** or **User Access Administrator** and **Contributor** roles satisfy the lab requirements.
- The [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli-windows) installed.
- PowerShell 6 or later and WinGet for the Windows installation steps.
- The [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) installed.
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running with Linux containers enabled.
- [Git](https://git-scm.com/downloads) installed.
- The files in this lab's `Labfiles/CaldovaInventory` folder.

To keep the timed exercise to 60 minutes, download the `mcr.microsoft.com/mssql/server:2022-latest` container image, install GitHub Copilot CLI, and register the `Microsoft.App` and `Microsoft.OperationalInsights` resource providers before the session. The SQL Server Linux container requires an x86-64 host. Use a prepared x86-64 lab environment if your device has an Arm processor.

> [!IMPORTANT]
> The password in the starter files is a synthetic local-development credential. Never submit real credentials, customer code, customer data, or confidential information to a prompt unless your organization's policies permit it.

> [!NOTE]
> This lab creates billable Azure resources. The cleanup section removes the resource group and all resources that the lab creates.

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
> Timebox this section to eight minutes. Record the three most important verified findings rather than every possible backlog item.

1. Select the **Chat** icon in Visual Studio Code, and select **Ask** from the mode picker.
1. Enter the following prompt to summarize the workload:

    ```prompt
    Analyze this workspace as a .NET and SQL Server modernization architect.
    Summarize the application architecture, request flow, framework and package
    dependencies, SQL Server touchpoints, configuration sources, container
    readiness, deployment assumptions, and runtime constraints. Include the
    supplied Dockerfile in the assessment. Cite the file that supports each claim.
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
> Timebox this section to 10 minutes. If Copilot doesn't produce a bounded change after one correction, replace the active files with the supplied reference files, run `dotnet build`, and continue to validation:
>
> ```powershell
> Copy-Item solution/Program.cs Program.cs -Force
> Copy-Item solution/appsettings.json appsettings.json -Force
> dotnet build
> ```

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

## Review the change with GitHub Copilot CLI

Use GitHub Copilot CLI as an independent review and validation surface. Keep the CLI scoped to the lab folder, review every requested tool action, and don't give it permission to edit files.

> [!TIP]
> Timebox this section to eight minutes. Use the interactive CLI so that you can inspect each proposed command before you approve it.

### Start and secure the CLI session

1. In the integrated terminal, verify that GitHub Copilot CLI is installed by running:

    ```powershell
    copilot --version
    ```

1. If the command isn't found, install GitHub Copilot CLI by running:

    ```powershell
    winget install GitHub.Copilot
    ```

    Close and reopen the terminal after installation, and then run `copilot --version` again.

1. Confirm that the terminal is open in the `Labfiles/CaldovaInventory` folder, and start an interactive session by running:

    ```powershell
    Remove-Item Env:ConnectionStrings__Inventory -ErrorAction SilentlyContinue
    copilot
    ```

    Clearing the environment variable keeps the synthetic database credential out of the CLI process environment. The build doesn't require a database connection.

1. When prompted to trust the folder, select the option to trust it for the current session. If you're prompted to authenticate, enter `/login` and follow the on-screen instructions.

    > [!IMPORTANT]
    > Copilot CLI can read, modify, and execute files in a trusted directory. Review each tool request and approve only the read operations and `dotnet build` command required by this section. Don't use `--allow-all-tools`, `/allow-all`, or `/yolo` in this lab.

### Review and build the bounded change

1. At the Copilot CLI prompt, enter:

    ```prompt
    Review @Program.cs, @appsettings.json, and @Dockerfile against these criteria:
    the Inventory connection string comes from ASP.NET Core configuration;
    startup rejects a missing, empty, or whitespace value with a clear message;
    appsettings.json contains no credential; the container listens on port 8080;
    and repositories, routes, packages, and compose.yaml remain unchanged. Do not
    edit files. Cite the file and relevant code for every conclusion. Mark
    unsupported claims as assumptions.
    ```

1. Review and approve only the file-read requests needed for the assessment. Confirm that the response addresses every acceptance criterion and correct any unsupported claim.
1. Enter the following prompt:

    ```prompt
    Run dotnet build without changing any files. Report whether the build succeeds,
    including the error and warning counts. If it fails, explain the first actionable
    error, but do not fix it.
    ```

1. When Copilot CLI requests permission to run `dotnet build`, review the exact command and approve that invocation only.
1. Confirm that Copilot CLI reports a successful build with no errors. Enter `/usage` to view the session summary, and then enter `/exit` to close the session.
1. Record the CLI review result, build result, and any difference from the Visual Studio Code review in `evidence/assessment-notes.md`.

The CLI review provides a second, terminal-based check while keeping you in control of file access and command execution.

## Validate the change and collect evidence

Run the application and verify the health and inventory read behavior observed in the baseline, then test the write path. This smoke test provides functional evidence, but it isn't a substitute for performance, security, and migration testing.

> [!TIP]
> Timebox this section to five minutes.

### Test the API

1. Restore the local connection string, and then start the application by running:

    ```powershell
    $env:ConnectionStrings__Inventory = "Server=localhost,14333;Database=CaldovaInventory;User Id=sa;Password=Caldova_Local_2026!;Encrypt=True;TrustServerCertificate=True"
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

Capture enough evidence to compare local and migrated behavior, and then stop the local application.

1. Record the build result, health result, read result, write result, and reviewed file diff in `evidence/assessment-notes.md`. Save the file by pressing **Ctrl+S**.
1. Return to the application terminal, and press **Ctrl+C** to stop the application.

The collected evidence shows that the bounded configuration change preserves the application's core database behavior.

## Migrate the workload to Azure Container Apps

Create a dedicated Azure environment, migrate the sample database to Azure SQL Database, and deploy the API to Azure Container Apps. The lab uses a public Azure SQL endpoint and SQL authentication to fit the timebox. Treat private networking and Microsoft Entra authentication as required production follow-up work.

> [!TIP]
> Timebox this section to 20 minutes. Azure resource creation and the first container revision can take several minutes.

### Prepare the Azure environment

1. Sign in to Azure, review the active subscription, and select the subscription you want to use:

    ```powershell
    az login
    az account show --query "{subscription:name, subscriptionId:id, tenantId:tenantId}" --output table
    $subscriptionId = Read-Host "Enter the subscription ID for this lab"
    az account set --subscription $subscriptionId
    ```

1. Install the Azure Container Apps extension and register the required resource providers:

    ```powershell
    az extension add --name containerapp --upgrade
    az provider register --namespace Microsoft.App --wait
    az provider register --namespace Microsoft.OperationalInsights --wait
    ```

1. Define unique names for the lab resources and generate a temporary SQL administrator password:

    ```powershell
    $suffix = [guid]::NewGuid().ToString("N").Substring(0, 8)
    $location = "eastus"
    $resourceGroup = "rg-caldova-modernize-$suffix"
    $sqlServer = "sql-caldova-$suffix"
    $databaseName = "CaldovaInventory"
    $sqlAdminUser = "caldovaadmin"
    $sqlAdminPassword = "Caldova!" + [guid]::NewGuid().ToString("N").Substring(0, 16)
    $registryName = "acrcaldova$suffix"
    $environmentName = "cae-caldova-$suffix"
    $containerAppName = "ca-caldova-$suffix"
    $identityName = "id-caldova-$suffix"
    $imageName = "caldova-inventory"
    ```

    Keep this PowerShell terminal open through cleanup. The generated password isn't written to a lab file or as a literal value in PowerShell history. It is expanded into process arguments for several lab commands and might be visible to local process inspection or command logging. Use this approach only for the synthetic lab credential. Production environments should use Microsoft Entra authentication and a secret store.

1. Create the resource group, Azure SQL logical server, and database:

    ```powershell
    az group create --name $resourceGroup --location $location
    az sql server create --name $sqlServer --resource-group $resourceGroup --location $location --admin-user $sqlAdminUser --admin-password $sqlAdminPassword
    az sql db create --resource-group $resourceGroup --server $sqlServer --name $databaseName --service-objective Basic
    ```

1. Add temporary firewall rules for your current public IP address and Azure-hosted resources:

    ```powershell
    $clientIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
    az sql server firewall-rule create --resource-group $resourceGroup --server $sqlServer --name AllowLabClient --start-ip-address $clientIp --end-ip-address $clientIp
    az sql server firewall-rule create --resource-group $resourceGroup --server $sqlServer --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    ```

    > [!IMPORTANT]
    > The `0.0.0.0` rule permits connections from Azure resources outside your subscription. Use this rule only for the timed lab. Production environments should use private endpoints, restricted network paths, and Microsoft Entra authentication.

1. Create the schema in Azure SQL Database, export the validated local table, and import its rows:

    ```powershell
    docker compose exec sql /opt/mssql-tools18/bin/sqlcmd -S "${sqlServer}.database.windows.net" -U $sqlAdminUser -P $sqlAdminPassword -d $databaseName -b -i /scripts/init-azure.sql
    docker compose exec sql /opt/mssql-tools18/bin/bcp CaldovaInventory.dbo.InventoryItems out /tmp/InventoryItems.bcp -S localhost -U sa -P "Caldova_Local_2026!" -n
    docker compose exec sql /opt/mssql-tools18/bin/bcp "${databaseName}.dbo.InventoryItems" in /tmp/InventoryItems.bcp -S "${sqlServer}.database.windows.net" -U $sqlAdminUser -P $sqlAdminPassword -n -E
    docker compose exec sql /opt/mssql-tools18/bin/sqlcmd -S "${sqlServer}.database.windows.net" -U $sqlAdminUser -P $sqlAdminPassword -d $databaseName -b -Q "SELECT COUNT(*) AS MigratedRows FROM dbo.InventoryItems;"
    ```

    Confirm that schema initialization completes, `bcp` copies four rows, and the query returns `4`. This offline table copy is suitable for the lab dataset. A production migration requires compatibility assessment, migration tooling, reconciliation, and a tested downtime or online-cutover plan.

### Build and deploy the container

1. Create an Azure Container Registry and enable Azure Resource Manager audience tokens:

    ```powershell
    az acr create --resource-group $resourceGroup --name $registryName --location $location --sku Basic
    az acr config authentication-as-arm update --registry $registryName --status enabled
    ```

    > [!NOTE]
    > The `az acr config authentication-as-arm` command group is in preview. The command enables the registry policy required for managed-identity image pulls. Preview command behavior can change before general availability.

1. Build the supplied `Dockerfile` in Azure Container Registry:

    ```powershell
    az acr build --registry $registryName --image "${imageName}:v1" .
    ```

    Confirm that the build finishes with `Run ID` and `Run status: Succeeded` values.

1. Create the Container Apps environment and a user-assigned managed identity:

    ```powershell
    az containerapp env create --name $environmentName --resource-group $resourceGroup --location $location
    az identity create --name $identityName --resource-group $resourceGroup --location $location
    $identityId = az identity show --name $identityName --resource-group $resourceGroup --query id --output tsv
    $principalId = az identity show --name $identityName --resource-group $resourceGroup --query principalId --output tsv
    ```

1. Grant the managed identity permission to pull images from the registry:

    ```powershell
    $registryId = az acr show --name $registryName --resource-group $resourceGroup --query id --output tsv
    az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --role AcrPull --scope $registryId
    ```

1. Build the Azure SQL connection string in memory, and deploy the container app:

    ```powershell
    $azureConnectionString = "Server=tcp:${sqlServer}.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$sqlAdminUser;Password=$sqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    $fqdn = az containerapp create --name $containerAppName --resource-group $resourceGroup --environment $environmentName --image "${registryName}.azurecr.io/${imageName}:v1" --target-port 8080 --ingress external --user-assigned $identityId --registry-server "${registryName}.azurecr.io" --registry-identity $identityId --secrets "inventory-connection-string=$azureConnectionString" --env-vars "ConnectionStrings__Inventory=secretref:inventory-connection-string" --min-replicas 1 --query properties.configuration.ingress.fqdn --output tsv
    $baseUrl = "https://$fqdn"
    $baseUrl
    ```

    The command stores the connection string as a Container Apps secret and exposes it to .NET configuration through `ConnectionStrings__Inventory`. It doesn't place the credential in the image or application settings file.

    If the command reports an image-pull authorization error, the `AcrPull` role assignment might still be propagating. Wait a few minutes, and then run the `az containerapp create` command again with the same variables.

### Validate the migrated workload

1. Verify the public health and inventory endpoints:

    ```powershell
    Invoke-RestMethod "$baseUrl/health"
    Invoke-RestMethod "$baseUrl/inventory" | Format-Table
    ```

    The first request might take a minute while the revision becomes ready. Confirm that the health response includes `Healthy` and that the inventory response contains four migrated rows from Azure SQL Database, including `CAL-400`.

1. Verify the cloud write path, and then repeat the read request:

    ```powershell
    $cloudBody = @{ sku = "CAL-500"; name = "Cloud gateway"; quantity = 10 } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "$baseUrl/inventory" -ContentType "application/json" -Body $cloudBody
    Invoke-RestMethod "$baseUrl/inventory" | Format-Table
    ```

    Confirm that the response assigns an `id` to `CAL-500` and that the final read returns five rows.

1. If a request fails, inspect the latest revision and console logs:

    ```powershell
    az containerapp revision list --name $containerAppName --resource-group $resourceGroup --query "[].{name:name, active:properties.active, replicas:properties.replicas}" --output table
    az containerapp logs show --name $containerAppName --resource-group $resourceGroup --type console --tail 50
    ```

1. Record the Azure resource names, public URL, image tag, health result, inventory results, and deployment issues in `evidence/assessment-notes.md`.

The application and sample data now run in Azure Container Apps and Azure SQL Database.

## Record the migration outcome

Use the evidence you collected to complete the modernization brief with actual deployment results rather than a proposed target.

> [!TIP]
> Timebox this section to four minutes. Keep the brief concise and don't invent production-readiness claims.

1. Select **Ask** in Copilot Chat, attach `evidence/assessment-notes.md` and `evidence/modernization-brief.md`, and enter:

    ```prompt
    Complete the modernization brief from the verified assessment and deployment
    evidence. Record Azure Container Apps and Azure SQL Database as the implemented
    lab targets. Include the top three blockers, configuration and containerization
    changes, deployed resources, validation evidence, temporary firewall risk,
    rollback direction, business value, and the next production-hardening wave.
    Do not invent workload facts, performance results, or production readiness.
    Label missing customer information as a discovery question.
    ```

1. Review the draft against your evidence. Confirm that it distinguishes a successful lab migration from production readiness.
1. Save `evidence/modernization-brief.md`, and confirm that it includes the deployed targets, validation evidence, risks, rollback direction, business value, and next wave.

## Summary

In this exercise, you used GitHub Copilot in Visual Studio Code and GitHub Copilot CLI to assess a .NET and SQL Server workload, externalize its database configuration, review its container readiness, migrate the sample data to Azure SQL Database, deploy the API to Azure Container Apps, and validate its public read and write paths.

You have successfully completed this exercise.

## Clean up

Remove the Azure and local resources after you finish the exercise.

1. In the PowerShell terminal that contains your Azure variables, verify the resource group name:

    ```powershell
    $resourceGroup
    ```

    If the variable is empty, set it to the resource group name that you recorded in `evidence/assessment-notes.md`.

1. Delete the dedicated resource group and all resources that the lab created:

    ```powershell
    az group delete --name $resourceGroup --yes
    az group exists --name $resourceGroup
    ```

    Confirm that the final command returns `false`.

    > [!CAUTION]
    > This command deletes every resource in the specified resource group. Confirm that the name identifies the dedicated lab resource group before you run it.

1. Open an integrated terminal in the `Labfiles/CaldovaInventory` folder. Stop the local environment and delete its data:

    ```powershell
    docker compose down --volumes
    ```

1. Clear the connection strings and generated password from the current PowerShell session:

    ```powershell
    Remove-Item Env:ConnectionStrings__Inventory -ErrorAction SilentlyContinue
    Remove-Variable azureConnectionString, sqlAdminPassword -ErrorAction SilentlyContinue
    ```

1. Confirm that the container is removed by running:

    ```powershell
    docker compose ps
    ```

## Additional resources

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [Install GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)
- [Use GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [Build and deploy an app to Azure Container Apps](https://learn.microsoft.com/azure/container-apps/tutorial-code-to-cloud)
- [Manage environment variables in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/environment-variables)
- [Use managed identity to pull images in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/managed-identity-image-pull)
- [Create and configure an Azure SQL database with the Azure CLI](https://learn.microsoft.com/azure/azure-sql/database/scripts/create-and-configure-database-cli)
- [Configure Azure SQL Database firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure)
