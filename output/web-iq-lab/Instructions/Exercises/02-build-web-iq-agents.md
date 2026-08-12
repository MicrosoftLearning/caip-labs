---
lab:
    title: 'Build Web IQ-grounded agents'
    description: 'Create Foundry agents that use Zava internal data and current public-web results.'
    level: 300
    duration: 45
    islab: true
    primarytopics:
        - Microsoft Foundry
        - Foundry Agent Service
        - Web search
        - Microsoft Fabric
---

# Build Web IQ-grounded agents

In this exercise, you create the four specialist agents used by the Zava Retail workflow. The Inventory Agent calls the published Fabric data agent. The Market-Intelligence Agent uses web search to retrieve current public information with citations. The Supervisor Agent classifies requests, and the Summarizer Agent combines specialist findings.

This exercise should take approximately **45** minutes to complete.

> [!NOTE]
> Web search and the Microsoft Fabric tool might be in preview or active development. Web search uses Grounding with Bing Search, incurs usage costs, and can transfer query data outside your compliance and geographic boundaries. Don't send confidential Zava data to web search.

## Prerequisites

To complete this exercise, you need:

- An Azure subscription with permission to create Foundry resources and deploy models.
- The published Fabric data agent from Exercise 1.
- The **Foundry User** role or equivalent permissions on the Foundry project.
- The `Labfiles/agent-instructions.md` file.

## Create a Foundry project

1. Open the [Microsoft Foundry portal](https://ai.azure.com) and sign in.
1. Ensure that **New Foundry** is enabled. The current workflow designer isn't available in hub-based classic projects.
1. In the upper-right menu, select **Build**, and then create a new project.
1. Expand **Advanced options**, and configure these settings:
    - **Project name**: `zava-web-iq`
    - **Foundry resource**: Create a new resource or use an existing resource.
    - **Subscription**: Your Azure subscription.
    - **Resource group**: Create or select a resource group.
    - **Region**: Select a region that supports your model and is compatible with your Fabric setup.
1. Select **Create** and wait for the project to open.

> [!NOTE]
> If your organization requires a hub, create it in Foundry (classic), then create a current Foundry project for this lab's agents and workflows. Hub-based projects aren't visible in the current portal.

## Deploy a model

1. In the Foundry portal, select **Discover** > **Model catalog**.
1. Search for `gpt-4.1` and open the model card.
1. Select **Deploy**, and use a Global Standard deployment when your subscription permits it.
1. Enter `zava-gpt-4-1` for the deployment name, and complete the deployment.
1. Return to **Build** > **Models**, and confirm that the deployment is ready.

If `gpt-4.1` isn't available in your region or quota, use another model shown as compatible with prompt agents, web search, and structured output.

## Connect the Fabric data agent

1. In Microsoft Fabric, open the published `Zava Inventory Data Agent`.
1. In the browser URL, locate and copy the GUID after `groups/` as the `workspace_id` and the GUID after `aiskills/` as the `artifact_id`.
1. Return to Foundry, open your project, and select **Management center** > **Connected resources**.
1. Select **New connection**.
1. Select **Microsoft Fabric**, enter the `workspace_id` and `artifact_id`, and save the connection as `zava-fabric-data`.
1. Confirm that the Fabric data agent and Foundry project are in the same tenant and that the data agent and data sources use capacity in the same region.

The Fabric tool uses identity passthrough. Service-principal authentication isn't supported for this connection.

## Create the Supervisor Agent

1. Select **Build** > **Agents**, and then select **Create agent**.
1. Name the agent `Supervisor Agent` and select the `zava-gpt-4-1` deployment.
1. Copy the **Supervisor Agent** instructions from `Labfiles/agent-instructions.md` into the instruction field.
1. In the response-format settings, select **JSON schema** and use this schema:

    ```json
    {
      "name": "routing_response",
      "schema": {
        "type": "object",
        "properties": {
          "route": { "type": "string", "enum": ["inventory", "market", "combined"] },
          "question": { "type": "string" }
        },
        "required": ["route", "question"],
        "additionalProperties": false
      },
      "strict": true
    }
    ```

1. Save the agent, and test `Which products are at risk of stockout?`.
1. Confirm that `route` is `inventory`.

## Create the Inventory Agent

1. Create another prompt agent named `Inventory Agent` that uses the same model deployment.
1. Add the **Microsoft Fabric data agent** tool, and select the `zava-fabric-data` connection.
1. Copy the **Inventory Agent** instructions from `Labfiles/agent-instructions.md`.
1. Save the agent, and test `Which products are at risk of stockout?`.
1. Confirm that the run invokes the Fabric tool and returns quantities from `stock_status`.

## Create the Market-Intelligence Agent

1. Create another prompt agent named `Market-Intelligence Agent` that uses the same model deployment.
1. Add the **Web search** tool. General web search doesn't require a separate Bing resource or project connection.
1. Copy the **Market-Intelligence Agent** instructions from `Labfiles/agent-instructions.md`.
1. Save the agent, and test `What are the current weather conditions in Memphis this week, and anything worth flagging for deliveries?`.
1. Confirm that the run invokes web search, states a forecast period, and includes citations.

## Create the Summarizer Agent

1. Create another prompt agent named `Summarizer Agent` that uses the same model deployment.
1. Don't add tools to this agent.
1. Copy the **Summarizer Agent** instructions from `Labfiles/agent-instructions.md`.
1. Save the agent.

The summarizer receives specialist output from the workflow. Keeping tools off this agent prevents a second search and makes source use easier to trace.

## Verify the agents

Confirm that the project contains these agents:

| Agent | Required tool | Expected role |
| --- | --- | --- |
| Supervisor Agent | None | Classify the request as inventory, market, or combined. |
| Inventory Agent | Microsoft Fabric data agent | Retrieve governed Zava data. |
| Market-Intelligence Agent | Web search | Retrieve current public-web information with citations. |
| Summarizer Agent | None | Combine supplied findings without adding facts. |

## Summary

In this exercise, you created four Foundry agents and grounded them in the appropriate source. The internal agent uses Fabric, while the external agent uses current public-web results.

You have successfully completed this exercise.

## Clean up

Keep the Foundry project, model deployment, connection, and agents for the remaining exercises.
