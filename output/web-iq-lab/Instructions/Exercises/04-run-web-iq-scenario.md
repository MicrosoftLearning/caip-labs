---
lab:
    title: 'Run the end-to-end Web IQ scenario'
    description: 'Test internal, external, and combined questions and inspect their execution traces.'
    level: 300
    duration: 25
    islab: true
    primarytopics:
        - Microsoft Foundry workflows
        - Web search
        - Application Insights tracing
---

# Run the end-to-end Web IQ scenario

In this exercise, you run four durable test prompts through the Zava Web IQ workflow. The tests show the difference between internal grounding, current public-web grounding, and a combined response. You then inspect the trace to verify which agents and tools ran.

This exercise should take approximately **25** minutes to complete.

> [!NOTE]
> Foundry visual workflows and workflow tracing are in preview. Foundry plans to retire visual workflows on December 1, 2026. For production solutions, implement this pattern with Microsoft Agent Framework.

## Prerequisites

To complete this exercise, you need the saved `Zava Web IQ Workflow` and enabled tracing from Exercise 3.

## Open the workflow Preview

1. In the Foundry portal, open the `zava-web-iq` project.
1. Select **Build**, and open `Zava Web IQ Workflow`.
1. Select **Run Workflow** to open the Preview chat.
1. Keep the workflow visualizer visible so you can observe each completed node.

## Test an external trend question

1. Enter `What products are trending in retail searches this week?`.
1. Confirm that the Supervisor Agent selects the market route.
1. Confirm that the Market-Intelligence Agent invokes web search.
1. Review the answer for a current time period, specific product trends, and web citations.

The exact answer changes over time. That variation demonstrates that the response comes from the current public web rather than the static Zava tables.

## Test current shipping-region weather

1. Enter `What are the current weather conditions in Memphis this week, and anything worth flagging for deliveries?`.
1. Confirm that only the market route runs.
1. Check that the answer states the forecast period and distinguishes conditions from delivery implications.
1. Confirm that calm weather is reported as a valid current result rather than treated as missing information.

## Test an internal stock question

1. Enter `Which products are at risk of stockout?`.
1. Confirm that the Supervisor Agent selects the inventory route.
1. Confirm that the Inventory Agent invokes the Fabric data agent and web search doesn't run.
1. Compare the returned quantities with the `stock_status` table from Exercise 1.

## Test the combined scenario

1. Enter:

    ```text
    Given what's trending in the market right now, are we adequately stocked to meet
    demand this week, and what are the current weather conditions for our carriers?
    ```

1. Confirm that the Supervisor Agent selects the combined route.
1. Confirm that both specialist agents run before the Summarizer Agent.
1. Review the final answer for these elements:
    - Zava stock quantities are labeled as internal data.
    - Market and weather claims include current web citations.
    - Recommendations connect external demand signals to actual Zava stock risk.
    - The response doesn't claim a weather disruption unless a source supports one.

## Inspect the combined trace

1. Open the workflow's **Traces** tab or select **Build** > **Agents** > **Traces**.
1. Sort by the newest timestamp and open the trace for the combined question.
1. Expand the supervisor span and verify that its route is `combined`.
1. Expand the Inventory Agent span and locate the Microsoft Fabric tool call.
1. Expand the Market-Intelligence Agent span and locate the web-search tool call and citations.
1. Expand the Summarizer Agent span and verify that both specialist outputs appear in its input.
1. Confirm that the trace doesn't show a Fabric tool call for either external-only test.

## Record the test results

Use this table to record whether each run followed the intended route:

| Prompt category | Expected specialist | Expected tool | Result |
| --- | --- | --- | --- |
| Trending products | Market Intelligence | Web search | Pass or investigate |
| Memphis weather | Market Intelligence | Web search | Pass or investigate |
| Stockout risk | Inventory | Fabric data agent | Pass or investigate |
| Combined planning | Inventory and Market Intelligence | Fabric data agent and web search | Pass or investigate |

If a route is wrong, refine the Supervisor Agent instructions with the failed prompt as an example. If a response lacks data, inspect the specialist tool call before changing the Summarizer Agent.

## Summary

In this exercise, you verified that the Zava workflow routes internal and external questions to different grounded sources, combines both sources for a planning question, and exposes each agent and tool call through a trace.

You have successfully completed this exercise.

## Clean up

Delete resources that you no longer need to avoid charges:

1. Delete the `zava-web-iq-app` Agent Application.
1. Delete the `zava-gpt-4-1` model deployment.
1. Delete the Foundry project or its Azure resource group.
1. Delete the `zava-web-iq-insights` Application Insights resource if it isn't removed with the resource group.
1. Delete the `Web IQ - Zava Retail` Fabric workspace.
