# Assess and improve Azure infrastructure resiliency

This 150-minute lab uses Caldova's accelerated V2 pharmaceutical product scenario to show how Infrastructure Resiliency Manager (preview) and the Azure Copilot Resiliency Agent (preview) support zonal resiliency assessment, planning, and validation.

Learners assess a representative Azure slice of Caldova's Supply Chain Planning Portal. They apply V2 launch, recovery, UK data-residency, hybrid network, and acquired-system constraints while reviewing posture, creating a service group, prioritizing recommendations, drafting remediation guidance and Bicep, and inspecting a prepared Availability Zone Down Drill without executing it.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Lab 3: Assess and improve Azure infrastructure resiliency](Instructions/Exercises/01-assess-improve-azure-infrastructure-resiliency.md) | Foundations, posture assessment, service-group goals, AI-assisted remediation, and drill readiness | 150 minutes |

## Lab environment

This portal-based lab requires an instructor-provisioned Azure environment. It doesn't include deployable lab files.

The prepared environment contains:

- An Azure Kubernetes Service (AKS) cluster representing the Supply Chain Planning Portal and distributed across availability zones.
- An Azure SQL planning database that isn't zone redundant.
- A locally redundant storage account for planning artifacts.
- An Azure Container Registry and a Standard Load Balancer.
- A service group named `CaldovaV2-SG` with a zonal resiliency goal and a prepared drill.
- Access to the Azure Copilot Resiliency Agent.

The resources contain synthetic data. They represent a modernization assessment and don't replace Caldova's current London and Miami datacenters, regulated manufacturing databases, segmented plant networks, or Litware PostgreSQL environment.

## Source documentation

- [Infrastructure Resiliency Manager overview (preview)](/azure/resiliency/infrastructure-resiliency-manager-overview)
- [Goals and recommendations in Infrastructure Resiliency Manager (preview)](/azure/resiliency/goals-recommendations-about)
- [Review recommendations in Infrastructure Resiliency Manager (preview)](/azure/resiliency/goals-recommendations-review-recommendations)
- [Azure Copilot Resiliency Agent (preview)](/azure/copilot/resiliency-agent)
- [Availability Zone Down Drills in Infrastructure Resiliency Manager (preview)](/azure/resiliency/availability-zone-down-drills-about)
- [Define an Availability Zone Down Drill (preview)](/azure/resiliency/availability-zone-down-drill-define)
- [Original Azure resiliency workshop](https://github.com/Azure/ResiliencyInAzure/blob/main/Labs/IRM_Lab.md)