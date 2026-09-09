# Modernize .NET and SQL Server with GitHub Copilot

This 45-minute lab uses the fictional Caldova inventory application to show how GitHub Copilot supports a bounded application and database modernization assessment.

Learners inspect an ASP.NET Core application backed by SQL Server, identify modernization blockers, externalize a database connection string, validate the application, and prepare a customer-ready Azure modernization recommendation.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Modernize a .NET and SQL Server workload with GitHub Copilot](Instructions/Exercises/01-modernize-dotnet-sql-copilot.md) | Assessment, bounded improvement, validation, and recommendation | 45 minutes |

## Lab files

- `Labfiles/CaldovaInventory` contains the starter ASP.NET Core application and local SQL Server environment.
- `Labfiles/CaldovaInventory/evidence` contains assessment and modernization brief templates.
- `Labfiles/CaldovaInventory/solution` contains reference files for the bounded improvement.

## Source documentation

- [Ask GitHub Copilot questions in your IDE](https://docs.github.com/copilot/using-github-copilot/copilot-chat/asking-github-copilot-questions-in-your-ide)
- [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [Azure App Service overview](https://learn.microsoft.com/azure/app-service/overview)
- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Kubernetes Service overview](https://learn.microsoft.com/azure/aks/what-is-aks)
- [SQL Server to Azure SQL Database migration overview](https://learn.microsoft.com/data-migration/sql-server/database/overview)
- [Compare Azure SQL Database and Azure SQL Managed Instance features](https://learn.microsoft.com/azure/azure-sql/database/features-comparison)
