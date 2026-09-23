---
lab:
    title: 'Lab 1 - L100: Introduction to resilient cloud design'
    description: 'Explore Azure availability zones, compare storage redundancy options, and use Infrastructure Resiliency Manager to examine the foundations of a resilient cloud design.'
    level: 100
    duration: 20
    islab: true
    primarytopics:
        - Azure reliability
        - Azure availability zones
        - Infrastructure Resiliency Manager
        - Azure Storage redundancy
        - Shared responsibility
---

# Lab 1 - L100: Introduction to resilient cloud design

Caldova operates business-critical inventory and replenishment applications on Azure. An interruption to the application or its data can delay warehouse operations, affect order fulfillment, and reduce confidence in inventory records. Caldova wants its teams to make reliability an explicit design requirement instead of treating recovery as a response to an outage.

In this exercise, you explore the Azure capabilities that support resilient cloud design. You examine availability-zone posture, compare storage redundancy options, apply the shared responsibility model, and navigate Infrastructure Resiliency Manager (IRM). This lab is inspection-only. You don't create or change Azure resources.

This exercise should take approximately **20** minutes to complete.

> [!NOTE]
> Infrastructure Resiliency Manager is in preview. Portal labels, available features, and evaluation results can change.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with access to the instructor-provisioned Caldova environment.
- **Reader** access to the prepared resources and service groups.
- **Service Group Reader** access to view application-level resiliency posture.
- An IRM usage plan enrolled for the prepared service groups.
- Access to the [Azure portal](https://portal.azure.com/).

The instructor-provisioned environment includes these service groups:

| Service group | Purpose |
| --- | --- |
| `CaldovaDayZero` | An empty service group reserved for a later design activity. |
| `CaldovaInventory` | A prepared service group that represents Caldova's inventory application. |

> [!NOTE]
> If your instructor provides different service-group names, record them and use those names throughout the exercise.

| Setting | Value |
| --- | --- |
| Subscription |  |
| Prepared resource group |  |
| Day-zero service group | `CaldovaDayZero` |
| Inventory service group | `CaldovaInventory` |

## Explore availability-zone resilience

Start with the Azure resiliency overview. It shows how Azure classifies individual resources based on their detected zonal configuration.

### Review the resiliency overview

1. Open the [Azure portal](https://portal.azure.com/), and sign in with the account assigned to the lab subscription.
1. Enter **Resiliency** in the search box, and then select **Resiliency**.
1. Expand **Infrastructure Resiliency** in the left menu, and then select **Overview**.
1. Review the resource summary and identify the counts for these posture categories:

    | Posture | Meaning |
    | --- | --- |
    | **Zone resilient** | IRM detects an Azure-recommended zonal resiliency solution. |
    | **Non-zone resilient** | IRM doesn't detect a zonal resiliency solution. |
    | **Not evaluated** | IRM can't evaluate the resource type or configuration. |

1. Record the category with the largest resource count in the prepared environment.
1. Select **Resource Resiliency**, and confirm that individual resources appear with a resiliency status.

You should now see how IRM summarizes the zonal posture of resources across the selected Azure scope.

### Apply the shared responsibility model

Azure provides regions, availability zones, and zone-redundant service options. Caldova remains responsible for selecting supported regions and service tiers, configuring resources to use those capabilities, and validating that the complete application meets its reliability requirements.

1. In **Resource Resiliency**, select a resource marked **Zone resilient**.
1. Review the detected resiliency solution and identify the configuration that supports the status.
1. Return to the resource list, and select a resource marked **Non-zone resilient**.
1. Select **View Recommendation**, and review the suggested configuration change.
1. Record which party owns each responsibility:

    | Responsibility | Azure or Caldova |
    | --- | --- |
    | Operate the physical datacenters that form an availability zone. |  |
    | Choose a region and service tier that support the required design. |  |
    | Configure workload resources for zone redundancy. |  |
    | Test whether the application continues to meet business requirements during a failure. |  |

1. Confirm that Azure owns operation of the platform, while Caldova owns workload configuration and validation.

> [!IMPORTANT]
> A **Zone resilient** resource status doesn't prove that the complete application is resilient. Application dependencies, data services, networking, monitoring, and recovery procedures must also support the intended outcome.

### Compare storage redundancy options

Use the storage account creation experience to compare redundancy choices without deploying a resource.

1. In the Azure portal, select **Create a resource**.
1. Search for and select **Storage account**, and then select **Create**.
1. On the **Basics** tab, choose the lab subscription, resource group, and region only when the portal requires them to display the available **Redundancy** options.
1. Open the **Redundancy** list, and compare the options available for the selected region and account configuration:

    | Option | Protection scope |
    | --- | --- |
    | Locally redundant storage (LRS) | Replicates data within one physical location in the primary region. |
    | Zone-redundant storage (ZRS) | Replicates data synchronously across availability zones in the primary region. |
    | Geo-redundant storage (GRS) | Adds asynchronous replication to a secondary region. |
    | Geo-zone-redundant storage (GZRS) | Combines zonal replication in the primary region with replication to a secondary region. |

1. Choose the option that best addresses a datacenter-level failure within one region, and record your reason.
1. Choose the option that adds protection from a regional disruption, and record one recovery consideration.
1. Select **Cancel**, and confirm that you don't create the storage account.

You have compared local, zonal, and regional redundancy choices without changing the lab environment.

## Navigate Infrastructure Resiliency Manager

IRM organizes resource posture, application goals, recommendations, recovery plans, and drills in one experience. Explore the available views and connect them to Caldova's reliability lifecycle.

### Explore the IRM views

1. Return to **Resiliency** > **Infrastructure Resiliency** in the Azure portal.
1. Review the available menu items:

    | View | Purpose |
    | --- | --- |
    | **Overview** | Summarizes resiliency posture across the Azure estate. |
    | **Resource Resiliency** | Shows detected posture for individual resources. |
    | **Service Group Resiliency** | Evaluates application resources against a shared resiliency goal. |
    | **Recommendations** | Provides guidance for detected resiliency gaps. |
    | **Recovery Plans** | Defines ordered recovery actions for an application. |
    | **Drills** | Supports controlled resilience validation. |
    | **Usage Plans** | Associates IRM usage with a billing subscription. |

1. Select **Service Group Resiliency**.
1. Identify the posture categories shown for service groups, such as **Zone resilient**, **Non-zone resilient**, **Goals not assigned**, and **Not evaluated**.
1. Confirm that `CaldovaDayZero` and `CaldovaInventory`, or the instructor-provided equivalents, appear in the list.

> [!TIP]
> If a menu item isn't available, record the difference. Preview availability can depend on tenant enrollment, permissions, region, and the configured usage plan.

### Examine the Caldova application boundary

A service group represents an application boundary rather than a single Azure resource. This view helps Caldova reason about the inventory application as a set of interdependent components.

1. Open `CaldovaInventory`.
1. Review the service-group goal, overall posture, and member resources without changing any settings.
1. Select one member resource, and compare its individual status with the service group's overall status.
1. Record your observations:

    | Question | Observation |
    | --- | --- |
    | What resiliency goal is assigned? |  |
    | Which member resources meet the goal? |  |
    | Which member resources don't meet the goal? |  |
    | Are any resources not evaluated? |  |
    | Which dependency presents the clearest business risk? |  |

1. Explain why one non-zone-resilient dependency can prevent the complete application from meeting a zone-resilient goal.
1. Return to the service-group list, and open `CaldovaDayZero`.
1. Confirm that the service group has no configured application members or goal. Don't add resources or assign a goal.

You should now be able to distinguish resource-level posture from application-level posture and identify where later design and remediation work begins.

## Connect resilience capabilities to Caldova's journey

Finish by mapping the IRM capabilities to the stages Caldova uses to improve and maintain reliability.

1. Match each customer moment to the relevant activity:

    | Customer moment | Activity |
    | --- | --- |
    | Start resilient | Define reliability requirements and choose resilient configurations before deployment. |
    | Get resilient | Assess an existing application, identify gaps, and plan remediation. |
    | Stay resilient | Monitor for drift, test recovery, and maintain evidence of readiness. |

1. Classify the following Caldova actions as **Start resilient**, **Get resilient**, or **Stay resilient**:

    - Select ZRS for a new inventory data store before deployment.
    - Review recommendations for an existing non-zone-resilient database.
    - Run an approved zone-down drill against a prepared application.
    - Detect that a resource no longer meets its assigned resiliency goal.

1. Record one business requirement that Caldova must define before choosing a technical design, such as an acceptable outage duration or data-loss limit.
1. Record one question that requires application-level evidence rather than the status of a single resource.

The mapping connects Azure platform capabilities to an ongoing reliability practice rather than a one-time configuration task.

## Summary

In this exercise, you explored availability-zone posture, applied the shared responsibility model, compared Azure Storage redundancy options, and navigated the core IRM views. You also examined Caldova's inventory application as a service group and connected resilience work to the start, get, and stay resilient journey.

You have successfully completed this exercise.

## Clean up

This inspection-only exercise doesn't create or change Azure resources. Confirm that you canceled the storage account creation page and didn't change either prepared service group. No further cleanup is required.

## Learn more

- [What are Azure availability zones?](/azure/reliability/availability-zones-overview)
- [Infrastructure Resiliency Manager overview](/azure/resiliency/infrastructure-resiliency-manager-overview)
- [Resiliency goals and recommendations](/azure/resiliency/goals-recommendations-about)
- [Azure Storage redundancy](/azure/storage/common/storage-redundancy)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)