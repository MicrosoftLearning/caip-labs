# Lab 1: Modernize a .NET application and SQL Server database with GitHub Copilot and CLI

This 60-minute lab uses the fictional Caldova inventory application to show how GitHub Copilot in Visual Studio Code and GitHub Copilot CLI support an application and database migration to Azure.

Learners inspect an ASP.NET Core application backed by SQL Server, identify modernization blockers, externalize a database connection string, review the change with GitHub Copilot CLI, migrate the database to Azure SQL Database, and deploy and validate the API in Azure Container Apps.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 1: Modernize a .NET application and SQL Server database with GitHub Copilot and CLI](Instructions/Exercises/01-modernize-dotnet-sql-copilot.md) | Assessment, configuration, CLI review, Azure SQL migration, and Container Apps deployment | 60 minutes |

## Lab files

- `Labfiles/CaldovaInventory` contains the starter ASP.NET Core application, local SQL Server environment, production Dockerfile, and Azure SQL seed script.
- `Labfiles/CaldovaInventory/evidence` contains assessment and modernization brief templates.
- `Labfiles/CaldovaInventory/solution` contains reference files for the bounded improvement.

## Source documentation

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [Install GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)
- [Use GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/copilot-cli/use-copilot-cli/overview)
- [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [Build and deploy an app to Azure Container Apps](https://learn.microsoft.com/azure/container-apps/tutorial-code-to-cloud)
- [Manage environment variables in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/environment-variables)
- [Create and configure an Azure SQL database with the Azure CLI](https://learn.microsoft.com/azure/azure-sql/database/scripts/create-and-configure-database-cli)
