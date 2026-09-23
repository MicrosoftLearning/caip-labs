---
lab:
    title: 'Lab 2 — L200: Resiliency posture review'
    description: 'Review Caldova’s Azure reliability posture with Azure Advisor, connect recommendations to business requirements, and create a prioritized improvement plan.'
    level: 200
    duration: 35
    islab: true
    primarytopics:
        - Azure Advisor
        - Advisor score
        - Azure reliability
        - Azure Well-Architected Framework
        - Resiliency posture
---

# Lab 2 — L200: Resiliency posture review

Caldova is preparing to launch an accelerated V2 pharmaceutical product while closing a 7% production gap across three manufacturing plants. The company must modernize its application estate without interrupting manufacturing, weakening regulated controls, or putting the product launch at risk. Before Caldova approves resilience investments, its architecture team needs a repeatable view of the Azure risks that require attention first.

In this exercise, you use Azure Advisor to establish a reliability baseline for Caldova’s instructor-provisioned Azure environment. You review the reliability score and recommendations, relate the findings to workload recovery requirements, and create a prioritized improvement plan. You don’t change resource configurations in this exercise.

This exercise should take approximately **35** minutes to complete.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription that contains the instructor-provisioned Caldova lab resources.
- Reader access to the lab subscription or resource group.
- Access to the [Azure portal](https://portal.azure.com/).
- At least one active Azure Advisor reliability recommendation in the prepared environment.

> [!IMPORTANT]
> Use only synthetic lab data. Caldova’s production GxP batch and quality records must remain in the United Kingdom and require validated access, encryption, policy, and audit controls. Don’t place regulated or customer data in the lab environment.

Record the values that your instructor provides:

| Setting | Value |
| --- | --- |
| Subscription |  |
| Resource group |  |
| Azure region |  |
| Prepared workload name |  |

## Establish the reliability baseline

Azure Advisor analyzes resource configuration and usage telemetry against Azure best practices. Start with the reliability score to create a point-in-time baseline for the prepared environment.

1. Open the [Azure portal](https://portal.azure.com/), and sign in with the account assigned to the lab subscription.
1. Enter **Advisor** in the portal search box, and then select **Advisor**.
1. Select **Advisor score**.
1. Set the subscription filter to the lab subscription.
1. Record the current results:

    | Measure | Observation |
    | --- | --- |
    | Overall Advisor score |  |
    | Reliability score |  |
    | Highest reliability subcategory |  |
    | Lowest reliability subcategory |  |
    | Reliability trend |  |

1. Review the reliability subcategories and identify which ones apply to Caldova’s workload:

    - **Zone Resiliency**.
    - **Regional Resiliency**.
    - **Data Protection and Recovery**.
    - **Governance and Compliance**.
    - **Scalability**.
    - **Monitoring and Alerting**.
    - **Service Upgrade and Retirement**.

Confirm that you have recorded a reliability baseline for the lab subscription.

> [!NOTE]
> Advisor scores include only resources that Advisor assesses. A score of 100% doesn’t prove that an application meets its recovery time objective (RTO), recovery point objective (RPO), regulatory obligations, or end-to-end availability target.

## Review the reliability recommendations

Move from the aggregated score to the resource-level findings. Scope the review to the lab environment so unrelated subscription resources don’t distort the assessment.

1. Select **Recommendations** in Azure Advisor.
1. Select the **Reliability** category.
1. Apply filters for the lab subscription and resource group.
1. Sort or group the recommendations by **Potential score increase**, **Impact**, or affected resource count, depending on the columns available in the portal.
1. Open the reliability recommendation with the highest potential score increase or broadest workload impact.
1. Record the recommendation details:

    | Finding | Observation |
    | --- | --- |
    | Recommendation |  |
    | Affected resource and service |  |
    | Reliability subcategory |  |
    | Potential score increase |  |
    | Proposed action |  |
    | Service, SKU, region, or cost prerequisite |  |

1. Return to the recommendation list, and review at least two more reliability recommendations.
1. Record all three findings in a comparison table:

    | Recommendation | Affected resource | Failure addressed | Business impact | Implementation dependency |
    | --- | --- | --- | --- | --- |
    | 1 |  |  |  |  |
    | 2 |  |  |  |  |
    | 3 |  |  |  |  |

Confirm that each recommendation is tied to an affected resource and a failure condition rather than only to a score increase.

> [!TIP]
> Advisor recommendations depend on the resources and configurations that the service evaluates. If the prepared environment shows fewer than three reliability recommendations, document every available finding and record the limited coverage as an assessment constraint.

## Connect findings to Caldova’s requirements

A platform recommendation becomes actionable only after you connect it to a business process and a measurable reliability target. Evaluate the Advisor findings against Caldova’s manufacturing and regulatory requirements.

1. Review Caldova’s requirements:

    | Workload or constraint | Requirement |
    | --- | --- |
    | Supply Chain Planning Portal | Five-minute continuity target and support for 500 requests per second. |
    | Manufacturing execution system and batch execution | Continuous availability for 24-hour production. |
    | `BatchManufacturingCore` | Maximum 30-minute data-loss tolerance. |
    | `BatchManufacturingCore` and `QualityLIMS` | UK data residency for GxP batch and quality records. |
    | Datacenter connectivity | No direct internet access, limited ExpressRoute bandwidth, and controlled firewall changes. |

1. Map each reviewed recommendation to the requirement that it supports.
1. Classify the recommendation by the failure scope it addresses:

    - Resource or component failure.
    - Availability zone failure.
    - Regional failure.
    - Data loss or corruption.
    - Capacity or demand increase.
    - Monitoring or operational response gap.

1. Determine whether implementing the recommendation would fully meet the requirement, partly support it, or require additional controls.
1. Record one residual risk for each recommendation.
1. Identify at least one Caldova requirement that the Advisor findings don’t assess.

Confirm that your review separates configuration guidance from proof that the complete workload meets its business target.

## Prioritize the improvement plan

Use the evidence from Advisor and the Caldova scenario to create a short improvement backlog. Don’t apply, dismiss, postpone, or mark recommendations as complete in the shared lab environment.

1. Rank the three findings by customer impact, regulatory risk, implementation dependencies, change risk, and potential score increase.
1. Complete the improvement plan:

    | Priority | Proposed improvement | Business requirement | Owner | Validation evidence | Next review |
    | ---: | --- | --- | --- | --- | --- |
    | 1 |  |  |  |  |  |
    | 2 |  |  |  |  |  |
    | 3 |  |  |  |  |  |

1. Assign the first improvement to the workload, platform, data, security, or compliance team.
1. Define the evidence required before approval, such as an architecture review, regional and SKU support check, cost estimate, deployment plan, restore test, failover test, or audit record.
1. Define a target review date that reflects the business impact and implementation risk.
1. Summarize the posture in three statements:

    - The strongest observed reliability control.
    - The most urgent gap.
    - The most important uncertainty that requires validation.

Confirm that the plan prioritizes business outcomes rather than treating Advisor score as the only success measure.

## Summary

In this exercise, you used Azure Advisor to establish a reliability baseline for Caldova’s Azure environment. You reviewed resource-level reliability recommendations, connected them to manufacturing and regulatory requirements, identified residual risks, and created a prioritized improvement plan without changing the shared environment.

You have successfully completed this exercise.

## Clean up

This exercise doesn’t create or modify Azure resources. Remove any filters that you applied in Azure Advisor so they don’t affect your next portal session. Don’t dismiss, postpone, complete, or apply recommendations in the shared lab environment.

## Learn more

- [Introduction to Azure Advisor](/azure/advisor/advisor-overview)
- [Advisor score](/azure/advisor/advisor-score)
- [Azure Advisor reliability recommendations](/azure/advisor/advisor-reference-reliability-recommendations)
- [Reliability in the Azure Well-Architected Framework](/azure/well-architected/reliability/)
- [Reliability guides for Azure services](/azure/reliability/overview-reliability-guidance)