---
lab:
    title: 'Build the multi-agent workflow'
    description: 'Orchestrate the Zava agents, publish the entry agent, and enable Application Insights tracing.'
    level: 300
    duration: 35
    islab: true
    primarytopics:
        - Microsoft Foundry workflows
        - Agent applications
        - Application Insights
---

# Build the multi-agent workflow

In this exercise, you use the Foundry visual workflow designer to route questions to the correct specialist agents. You then connect Application Insights for server-side tracing and publish the supervisor entry agent as an Agent Application.

This exercise should take approximately **35** minutes to complete.

> [!NOTE]
> Foundry visual workflows and workflow tracing are in preview. Foundry plans to retire visual workflows on December 1, 2026. For production solutions, implement this pattern with Microsoft Agent Framework.

## Prerequisites

To complete this exercise, you need the Foundry project and four agents from Exercise 2. You also need permission to create an Application Insights resource and publish agents. To query trace telemetry, you need the **Log Analytics Reader** role on the connected Application Insights resource. If its Log Analytics tables are protected, you also need the **Privileged Monitoring Data Reader** role.

## Connect Application Insights

1. In the Foundry portal, open the `zava-web-iq` project.
1. Select **Build** > **Agents**, and then select the **Traces** tab.
1. Select **Connect**.
1. Create a new Application Insights resource named `zava-web-iq-insights`, or select an existing resource.
1. Complete the connection and wait until tracing shows as enabled.

Server-side tracing requires no code changes. Foundry begins recording agent and workflow runs after the connection is active.

> [!IMPORTANT]
> Traces can contain prompts, model responses, tool arguments, and tool results. Don't use secrets or personal data in this lab. Apply appropriate access controls and retention settings to Application Insights.

## Create the workflow

1. Select **Build**, and then select **Create new workflow**.
1. Select a custom or sequential workflow template, and name the workflow `Zava Web IQ Workflow`.
1. Add an **Ask a question** node, enter `How can Zava Retail help?`, and save the user response as `question`.
1. Add an **Invoke agent** node, select the existing `Supervisor Agent`, and enter `{Local.question}` as its input.
1. In **Action settings**, select **Save output json_schema as**, create a variable named `routing`, and select **Done**.
1. Add an **If/else** node after the supervisor.
1. Create three branches with these Power Fx conditions:
    - Inventory: `Local.routing.route = "inventory"`.
    - Market: `Local.routing.route = "market"`.
    - Combined: `Local.routing.route = "combined"`.

> [!IMPORTANT]
> Foundry doesn't save workflow changes automatically. Select **Save** after each branch is complete.

## Configure the inventory route

1. On the `inventory` branch, add an **Invoke agent** node for `Inventory Agent`.
1. Enter `{Local.routing.question}` as the input. In **Action settings**, save the text output as `inventory_findings`.
1. Add a **Set a variable** node that creates `market_findings` with the text value `Not requested`.
1. Add an **Invoke agent** node for `Summarizer Agent`.
1. Pass `{Local.question}`, `{Local.inventory_findings}`, and `{Local.market_findings}` in a labeled text block. Save the text output as `summary`.
1. Add a **Send a message** node with `{Local.summary}` as the message.

## Configure the market route

1. On the `market` branch, invoke `Market-Intelligence Agent` with `{Local.routing.question}`.
1. In **Action settings**, save its text output as `market_findings`.
1. Add a **Set a variable** node that creates `inventory_findings` with the text value `Not requested`.
1. Invoke `Summarizer Agent` with `{Local.question}`, `{Local.inventory_findings}`, and `{Local.market_findings}` in a labeled text block. Save the text output as `summary`.
1. Add a **Send a message** node with `{Local.summary}` as the message.

## Configure the combined route

1. On the `combined` branch, invoke `Inventory Agent` with `{Local.routing.question}`, and save the text output as `inventory_findings`.
1. Invoke `Market-Intelligence Agent` with `{Local.routing.question}`, and save the text output as `market_findings`.
1. Invoke `Summarizer Agent` with this input pattern:

    ```text
    User question:
    {Local.question}

    Inventory findings from Zava internal data:
    {Local.inventory_findings}

    Market findings from public web search:
    {Local.market_findings}
    ```

1. Save the summarizer text output as `summary`, and add a **Send a message** node with `{Local.summary}` as the message.
1. Select **Save**.

The specialist calls on the combined route can run sequentially for this lab. In a production Agent Framework workflow, run independent calls concurrently to reduce latency.

## Test the workflow

1. Select **Run Workflow**.
1. Enter `Which products are at risk of stockout?`.
1. Confirm that the supervisor and inventory nodes complete, while the market node doesn't run.
1. Enter `What products are trending in retail searches this week?`.
1. Confirm that the supervisor and market nodes complete, while the inventory node doesn't run.
1. Save any workflow changes.

## Publish the entry agent

Visual workflows run in the workflow Preview experience. Current Foundry publishing creates an Agent Application from an agent version, not from a visual workflow. Publish the supervisor as the stable entry application while retaining the workflow for this lab's orchestration tests.

1. Open `Supervisor Agent` in the Agent Builder.
1. Select the current version, and then select **Publish**.
1. Name the Agent Application `zava-web-iq-app` and use the Responses protocol.
1. Wait for the deployment to reach the running state.
1. Record the application endpoint.

> [!NOTE]
> The published supervisor classifies requests but doesn't execute the visual workflow by itself. Production publishing requires implementing the orchestration with Microsoft Agent Framework or an application service, then exposing that implementation through an endpoint.

## Verify tracing

1. Return to the workflow and run one more test question.
1. Select the workflow's **Traces** tab, or open **Build** > **Agents** > **Traces**.
1. Open the newest trace.
1. Confirm that the trace contains spans for the supervisor, the selected specialist, model calls, and tool calls.
1. Select the conversation details and review the ordered inputs and outputs.

## Summary

In this exercise, you built conditional multi-agent orchestration, enabled server-side tracing with Application Insights, and published the supervisor entry agent as an Agent Application.

You have successfully completed this exercise.

## Clean up

Keep the workflow, application, and Application Insights resource for Exercise 4.
