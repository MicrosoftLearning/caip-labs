---
lab:
    title: 'Lab 3: Assess and improve Azure infrastructure resiliency'
    description: 'Use Infrastructure Resiliency Manager and the Azure Copilot Resiliency Agent to assess zonal resiliency, define application goals, plan remediation, and inspect a prepared Availability Zone Down Drill.'
    level: 300
    duration: 150
    islab: true
    primarytopics:
        - Infrastructure Resiliency Manager
        - Azure Copilot Resiliency Agent
        - Azure availability zones
        - Azure Service Groups
        - Azure Advisor
        - Bicep
        - Azure Chaos Studio
---

# Lab 3: Assess and improve Azure infrastructure resiliency

Caldova is a pharmaceutical company preparing to launch an accelerated V2 product ahead of a competitor. The company must close a 7% production capacity gap across three manufacturing plants while it modernizes a fragmented estate that includes legacy .NET applications, on-premises SQL Server and PostgreSQL databases, and VMware infrastructure that is past renewal.

This lab uses an instructor-provisioned Azure workload that represents a modernized slice of Caldova's Supply Chain Planning Portal. Its Azure Kubernetes Service (AKS) cluster spans three availability zones, but its Azure SQL database and storage account don't use zone-redundant configurations. A zone outage could leave the compute tier available while disrupting planning data during the V2 launch. The lab resources contain synthetic data and don't represent Caldova's regulated production systems.

In this exercise, you use Infrastructure Resiliency Manager (IRM) to examine this application as a complete service, identify zonal resiliency gaps, and set a resiliency goal. You then use the Azure Copilot Resiliency Agent to draft remediation guidance and infrastructure as code (IaC). Finally, you inspect a prepared Availability Zone Down Drill and its permissions without starting the drill.

This exercise should take approximately **150** minutes to complete.

> [!IMPORTANT]
> IRM, Availability Zone Down Drills, and the Azure Copilot Resiliency Agent are preview features. Preview behavior and portal labels can change. Don't use the generated guidance or code in production until you validate it through your organization's architecture, security, cost, and deployment review processes.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with the instructor-provisioned lab resources.
- Contributor or Owner access for the resource grouping task.
- **Service Group Reader** access to view service-group recommendations and **Reader** access to the member resources.
- An IRM usage plan enrolled for the prepared service group.
- Access to the [Azure portal](https://portal.azure.com/).
- A tenant allowlisted for the Resiliency Agent, with **Agents (Preview)** enabled in the Azure Copilot admin center.
- A prepared service group named `CaldovaV2-SG` with a zonal resiliency goal and an Availability Zone Down Drill in the **Ready** state.

The instructor-provisioned application includes these resources:

| Application component | Azure service | Prepared configuration |
| --- | --- | --- |
| Supply Chain Planning Portal | AKS | Node pools use zones 1, 2, and 3 |
| V2 planning database | Azure SQL Database | Zone redundancy isn't enabled |
| Planning artifacts | Azure Storage | Standard locally redundant storage |
| Application images | Azure Container Registry | Included in the service group |
| Portal traffic routing | Azure Load Balancer | Standard SKU |

> [!NOTE]
> IRM is a global, nonregional service. It can evaluate resources across Azure regions, but each resource's supported zonal configuration still depends on its service, SKU, and region.

## Apply the Caldova decision context

Caldova needs a prioritized roadmap that connects resiliency improvements to V2 launch readiness, manufacturing continuity, and regulatory risk. Use the following requirements when you evaluate recommendations throughout the lab:

Caldova's current estate provides the wider context for the representative Azure workload:

| Current-state component | Role and constraint |
| --- | --- |
| `CALD-SQL-PROD01` in London | Hosts the primary manufacturing databases, including the 8-TB `BatchManufacturingCore` database. |
| `CALD-SQL-REPORT01` and `CALD-SQL-LEGACY01` in London | Support reporting and the legacy pharmacy gateway. |
| `CALD-SQL-DR01` in Miami | Receives asynchronous availability-group replication from London. |
| Litware PostgreSQL server | Hosts the acquired manufacturing database on-premises. |
| Legacy .NET and VMware estate | Includes the supply chain planning application and infrastructure that is past renewal. |
| Plant MES and IoT networks | Remain segmented from IT and exchange data only through approved perimeter brokers. |

| Business consideration | Caldova requirement | How to use it in this lab |
| --- | --- | --- |
| V2 product launch | Avoid changes that delay the 16-week modernization window or overlap process validation runs. | Identify sequencing, downtime, and rollback assumptions. |
| Supply Chain Planning Portal | Recover within 5 minutes and support 500 requests per second during peak demand. | Treat backend dependencies as part of the complete service. |
| Batch Release and QA Console | Recover within 2 minutes and support 200 requests per second. | Record this as a stricter downstream requirement, even though the console isn't deployed in the lab. |
| MES and Batch Execution Service | Maintain continuous availability and support 100 requests per second. | Don't infer that a zonal planning workload satisfies plant execution requirements. |
| Regulated data | Keep `BatchManufacturingCore` and `QualityLIMS` data in the UK. | Require region and data-residency validation before accepting generated guidance. |
| Hybrid connectivity | Account for no direct server internet access, a proxy with SSL inspection, limited ExpressRoute bandwidth, and firewall lead times of two to four weeks. | Treat connectivity and operational dependencies as explicit remediation prerequisites. |
| Litware acquisition | Integrate the on-premises PostgreSQL manufacturing environment without weakening controls. | Record acquired-system dependencies that IRM can't infer from the prepared Azure service group. |

> [!IMPORTANT]
> A zonal resiliency assessment of the prepared Azure resources doesn't prove end-to-end resiliency for Caldova. The current estate also depends on London and Miami datacenters, segmented plant networks, approved perimeter brokers, partner services, and Litware systems. Record these as external dependencies instead of assuming that IRM discovers them automatically.

## Explore zonal resiliency in IRM

Start with the at-scale views so that you understand the difference between individual resource posture and application-level posture.

### Review the resource-level view

1. Open the [Azure portal](https://portal.azure.com/), and sign in with the account assigned to the lab subscription.
1. Enter **Resiliency** in the search box, and then select **Resiliency**.
1. Expand **Infrastructure Resiliency** in the left menu, and then select **Overview**.
1. Review the resource and service-group summary tiles.
1. Select **Resource Resiliency**, and identify the available posture categories:

    - **Zone resilient** means that IRM detects an Azure-recommended zonal resiliency solution.
    - **Non-zone resilient** means that IRM doesn't detect a zonal resiliency solution.
    - **Not evaluated** means that IRM can't evaluate the resource type or configuration.

1. Select a zone-resilient resource and review the detected solution.
1. Select a non-zone-resilient resource, and then select **View Recommendation**.

    Confirm that the recommendation identifies the affected resource, explains the resiliency gap, and provides remediation guidance.

### Compare storage redundancy options

1. Select **Create a resource** in the Azure portal.
1. Search for and select **Storage account**, and then select **Create**.
1. Review the available **Redundancy** values on the **Basics** tab. Availability depends on the selected region and account configuration.
1. Compare these common options:

    - Locally redundant storage (LRS) keeps copies in one physical location within the primary region.
    - Zone-redundant storage (ZRS) replicates data synchronously across availability zones in the primary region.
    - Geo-redundant storage (GRS) and geo-zone-redundant storage (GZRS) add replication to a secondary region.

1. Select **Cancel**. Don't create the storage account.

You now have a resource-level baseline and understand that Azure supplies zonal capabilities while the workload owner chooses and configures the appropriate solution.

## Assess application posture

Use a service group to review the resources in the context of one application and one shared resiliency goal.

### Inspect the prepared service group

1. Select **Service Group Resiliency** under **Infrastructure Resiliency**.
1. Review the service groups by status:

    - **Zone resilient**.
    - **Non-zone resilient**.
    - **Goals not assigned**.
    - **Not evaluated**.

1. Select `CaldovaV2-SG`.
1. Confirm that its resiliency goal is **Zone resilient**.
1. Review each member's status, and compare it with the prepared configuration in the prerequisites table.
1. Confirm that one non-zone-resilient member makes the service group's overall posture non-zone-resilient.

> [!NOTE]
> A service group models an application boundary. It can include resources from multiple resource groups or subscriptions, and a shared resource can belong to more than one service group.

### Review targeted recommendations

1. Select **Goals and Recommendations** in `CaldovaV2-SG`.
1. Scroll to the **Recommendations** section.
1. Open the recommendation for the Azure SQL database, and record:

    - The rationale.
    - The remediation steps.
    - The qualitative cost implication, if available.

1. Return to the recommendation list, and repeat the review for the storage account.
1. Record which change you would assess first based on V2 launch impact, the 5-minute portal recovery requirement, prerequisites, cost, and implementation risk.

> [!TIP]
> Recommendations can take time to appear after resources or goals change. If the prepared recommendations aren't available, continue to the Resiliency Agent section and treat the missing recommendation as an environment observation.

### Compare service-group and resource views

1. Select **Resource Resiliency** under **Infrastructure Resiliency**.
1. Filter the list to the lab resource group.
1. Note that this view shows resources independently of application membership.
1. Return to **Service Group Resiliency**, and open `CaldovaV2-SG`.
1. Note that this view evaluates the same resources against a shared application goal.

The service-group view now shows which dependencies prevent the complete application from meeting its zonal resiliency goal.

## Define and plan resiliency improvements

Create a separate service group for your assessment. Don't change the configuration of the shared resources during this lab.

### Create a service group

1. Select **Resource Resiliency** under **Infrastructure Resiliency**.
1. Filter the list to the instructor-provisioned resource group.
1. Select the AKS cluster, Azure SQL database, storage account, load balancer, and container registry.
1. Select **Create Service group**.
1. Enter `CaldovaV2-<unique-id>` as the service-group name, replacing `<unique-id>` with your initials and a number. Leave **Parent service group** empty.
1. Review the prepopulated members, and then select **Create**.

    Confirm that the new service group appears with the **Goals not assigned** status.

### Assign a zonal resiliency goal

1. Select **Service Group Resiliency** under **Infrastructure Resiliency**.
1. Open the service group that you created.
1. Select the option to assign a goal.
1. Set the goal to **Zone resilient**, and save the change.
1. Review the resulting counts for zone-resilient, non-zone-resilient, and not-evaluated resources.

> [!NOTE]
> The evaluation can take several minutes. Continue when the status appears, or use `CaldovaV2-SG` for the remaining read-only tasks.

### Prioritize the recommendations

1. Select **Goals and Recommendations** in your service group.
1. Review each available recommendation and its qualitative cost implication.
1. Create a short action plan with these columns:

    | Priority | Resource | Business requirement | Proposed change | Prerequisites | Validation needed |
    | ---: | --- | --- | --- | --- | --- |
    | 1 |  |  |  |  |  |
    | 2 |  |  |  |  |  |

1. Rank the changes by V2 launch impact, recovery requirement, regulatory risk, dependencies, implementation risk, and cost. Don't apply the recommendations.
1. Record any dependency that IRM doesn't show, including on-premises databases, plant-floor brokers, partner application programming interfaces (APIs), or the Litware PostgreSQL environment.

### Open the Resiliency Agent

1. Select the **Copilot** icon in the Azure portal header.
1. Select **Resiliency** in the agent selector.
1. Confirm with your instructor that the tenant is allowlisted and **Agents (Preview)** is enabled if **Resiliency** isn't available.

### Generate remediation guidance

1. Enter this prompt in the Copilot pane, replacing the placeholder with your service-group name:

    ```prompt
    Assess the zonal resiliency of service group <service-group-name>.
    This service group represents Caldova's Supply Chain Planning Portal, which
    must recover within 5 minutes and support 500 requests per second. Caldova
    has a 16-week modernization window, no direct internet access from datacenter
    servers, limited ExpressRoute bandwidth, and firewall lead times of 2 to 4
    weeks. Regulated GxP data must remain in the UK.
    For each resource that doesn't meet the goal, explain the detected gap,
    prerequisites, whether remediation is in-place or requires redeployment,
    expected service interruption, qualitative cost impact, rollback approach,
    and the validation needed. Identify assumptions and external dependencies
    that aren't visible in the service group. Don't make any changes.
    ```

1. Compare the response with IRM's recommendations.
1. Mark unsupported claims as assumptions, especially claims about downtime, recovery objectives, UK data residency, network access, region support, SKU support, cost, and in-place conversion.
1. Ask the agent to cite the Azure configuration that supports each posture claim.

The agent's response varies with the current resource configuration. Treat it as a draft plan, not as evidence that a change is safe.

### Generate and review Bicep

1. Enter this prompt in the same conversation:

    ```prompt
    Generate modular Bicep for a new zone-resilient Azure SQL database and
    storage account based on this service group. Treat the resources as a
    nonproduction Caldova V2 planning workload with synthetic data. Use UK
    regions only when the required services and SKUs are supported. Use stable
    API versions.
    Include parameters rather than secrets or fixed resource names. Explain
    region, residency, networking, and SKU prerequisites, cost tradeoffs, and
    any settings that can't be inferred. Don't deploy or modify existing resources.
    ```

1. Confirm that the generated SQL database resource includes an appropriate zone-redundancy setting.
1. Confirm that the generated storage account uses a zone-redundant SKU such as `Standard_ZRS`, when the selected region and scenario support it.
1. Confirm that resource names, locations, administrator values, network controls, and other environment-specific settings are parameters rather than invented production values.
1. Confirm that the generated design doesn't claim to migrate `BatchManufacturingCore`, `QualityLIMS`, or Litware's PostgreSQL database.
1. Enter this validation prompt:

    ```prompt
    Review the Bicep you generated. List unresolved parameters and assumptions,
    check resource API versions and parent-child relationships, and explain how
    I should run Bicep lint and an Azure what-if operation before deployment.
    Don't deploy or modify resources.
    ```

1. Record any issue that the second review finds and the independent checks still required.

> [!IMPORTANT]
> A conversational review isn't proof that Bicep compiles or that Azure accepts the deployment. In a real delivery workflow, save the files in source control, run the Bicep linter, run an Azure what-if operation against a nonproduction scope, and require peer approval before deployment.

## Inspect drill readiness

Availability Zone Down Drills use controlled fault injection to evaluate cross-zone behavior. This section uses the shared prepared drill in read-only mode.

> [!WARNING]
> Don't create or execute a drill in this lab. Fault injection can interrupt workloads and incur charges. Use only the prepared drill, and don't change its identity, permissions, faults, monitoring, or recovery plan.

### Review drill prerequisites

1. Select **Drills** under **Infrastructure Resiliency**.
1. Open the prepared drill associated with `CaldovaV2-SG`.
1. Confirm that a recovery plan is associated with the service group.
1. Confirm with the instructor that these resource providers are registered in the drill subscription:

    - `Microsoft.Chaos`.
    - `Microsoft.Insights`.
    - `Microsoft.OperationalInsights`.
    - `Microsoft.Automation`.

1. Confirm that **Drill execution readiness** displays **Ready**. If it doesn't, record the failed readiness check and don't continue to an execution screen.

### Inspect identities and resources

1. Select **Settings** > **Identity and permissions** in the prepared drill.
1. Select **View details** under **Role assignment status**.
1. Confirm that the identities required for fault injection, recovery, and monitoring show successful role assignments.
1. Return to the drill, and open the resource or fault design view.
1. Identify which resources qualify for fault injection and which resources IRM excludes.
1. Record whether an excluded resource lacks native zonal resiliency, isn't part of the recovery plan, or isn't supported for zonal resiliency detection.

### Review the execution boundary

1. Return to the prepared drill's **Overview** page.
1. Locate **Execute drill**, but don't select it.
1. Review the documented lifecycle:

    - Verify recovery-plan readiness.
    - Select the source region and availability zone.
    - Inject the approved faults.
    - Monitor application and resource health.
    - Perform failover or reprotection when the recovery plan requires it.
    - End the drill and review the results.

1. Identify the application health signals and stop criteria that the workload team would need before approving an execution.
1. Confirm that the proposed drill window doesn't overlap a V2 process validation run or an active manufacturing change freeze.
1. Record how the team would validate the Supply Chain Planning Portal's 5-minute recovery target and 500-requests-per-second peak requirement.

You have inspected the controls required to prepare a zonal outage simulation without affecting the shared environment.

## Summary

In this lab, you:

- Compared resource-level and application-level zonal resiliency posture.
- Applied Caldova's V2 launch, recovery, residency, and hybrid network requirements to a representative Azure workload.
- Identified backend and external dependencies that prevent an application from meeting its goal.
- Created a service group and assigned a zonal resiliency goal.
- Prioritized recommendations without changing shared resources.
- Used the Resiliency Agent to draft and critically review remediation guidance and Bicep.
- Inspected drill readiness, identities, faults, and execution boundaries without injecting faults.

You have successfully completed this exercise.

## Clean up the service group

Remove only the service group that you created. Don't delete the shared `CaldovaV2-SG` service group or any Azure resources.

1. Select **Service Group Resiliency** under **Infrastructure Resiliency**.
1. Open `CaldovaV2-<unique-id>`.
1. Select **Delete**, and confirm the deletion when prompted.
1. Return to the service-group list, and confirm that your service group no longer appears.

## Learn more

- [Infrastructure Resiliency Manager overview (preview)](/azure/resiliency/infrastructure-resiliency-manager-overview)
- [Assign goals and view resiliency posture (preview)](/azure/resiliency/goals-recommendations-assign-goals-view-posture)
- [Review recommendations (preview)](/azure/resiliency/goals-recommendations-review-recommendations)
- [Azure Copilot Resiliency Agent (preview)](/azure/copilot/resiliency-agent)
- [About Availability Zone Down Drills (preview)](/azure/resiliency/availability-zone-down-drills-about)
- [Define an Availability Zone Down Drill (preview)](/azure/resiliency/availability-zone-down-drill-define)
- [Execute an Availability Zone Down Drill (preview)](/azure/resiliency/availability-zone-down-drill-execute)