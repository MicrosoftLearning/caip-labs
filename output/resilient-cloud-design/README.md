# Introduction to resilient cloud design

This 20-minute, portal-based lab introduces resilient cloud design through the fictional Caldova inventory application.

Learners explore availability-zone posture, compare Azure Storage redundancy options, apply the shared responsibility model, navigate Infrastructure Resiliency Manager, and distinguish resource-level posture from application-level posture. The lab is read-only and creates no Azure resources.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 1 - L100: Introduction to resilient cloud design](Instructions/Exercises/01-introduction-to-resilient-cloud-design.md) | Availability zones, shared responsibility, storage redundancy, IRM navigation, and customer resilience journeys | 20 minutes |

## Lab environment

This portal-based lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- Resources with a mix of zone-resilient, non-zone-resilient, and not-evaluated states.
- A prepared service group named `CaldovaInventory` that represents the inventory application.
- An empty service group named `CaldovaDayZero` for later workshop activities.
- Reader and Service Group Reader access for inspection-only tasks.
- An enrolled Infrastructure Resiliency Manager usage plan.

## Source documentation

- [What are Azure availability zones?](/azure/reliability/availability-zones-overview)
- [Infrastructure Resiliency Manager overview](/azure/resiliency/infrastructure-resiliency-manager-overview)
- [Resiliency goals and recommendations](/azure/resiliency/goals-recommendations-about)
- [Azure Storage redundancy](/azure/storage/common/storage-redundancy)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)
- [Original Azure resiliency workshop](https://github.com/Azure/ResiliencyInAzure/blob/main/Labs/IRM_Lab.md)