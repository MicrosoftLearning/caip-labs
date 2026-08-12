# Building intelligent solutions with Microsoft Web IQ

This lab uses the Zava Retail scenario to build a multi-agent solution that combines governed business data in Microsoft Fabric with current public-web information in Microsoft Foundry.

Learners create a Fabric data agent for inventory questions, a web-grounded market-intelligence agent, a supervisor that classifies requests, and a summarizer that produces one response. They then assemble and trace the workflow in the Foundry visual workflow designer.

## Lab structure

| Exercise | Focus | Duration |
| --- | --- | ---: |
| [Build the Web IQ lab foundation](Instructions/Exercises/01-build-web-iq-foundation.md) | Fabric workspace, lakehouse, notebook, and data agent | 45 minutes |
| [Build Web IQ-grounded agents](Instructions/Exercises/02-build-web-iq-agents.md) | Foundry project, model, Fabric tool, web search, and agents | 45 minutes |
| [Build the multi-agent workflow](Instructions/Exercises/03-build-multi-agent-workflow.md) | Conditional orchestration, publishing, and tracing | 35 minutes |
| [Run the end-to-end scenario](Instructions/Exercises/04-run-web-iq-scenario.md) | Internal, external, combined, and trace tests | 25 minutes |

The complete lab takes approximately **150 minutes**.

## Architecture

```text
User question
    |
    v
Supervisor Agent
    |-- internal --> Inventory Agent --> Fabric data agent --> Zava Lakehouse
    |-- external --> Market-Intelligence Agent --> Web search
    `-- combined --> both specialist agents
                          |
                          v
                    Summarizer Agent
                          |
                          v
                  Grounded response
```

## Lab files

- `Labfiles/data/` contains synthetic Zava Retail data.
- `Labfiles/notebooks/load-zava-retail-data.ipynb` loads the CSV files into Delta tables.
- `Labfiles/agent-instructions.md` contains the agent instructions used in Exercise 2.

## Important product notes

- Microsoft documentation describes live public-web grounding as the **web search tool** in Foundry Agent Service. This lab uses **Web IQ** as the solution pattern that applies this capability.
- The current Foundry experience uses a **Foundry resource and project**. Hub-based projects belong to Foundry (classic) and don't expose the current multi-agent workflow experience.
- Foundry visual workflows are in preview and are scheduled for retirement on December 1, 2026. Use Microsoft Agent Framework for new production workflows. This lab uses the visual designer because it makes routing and traces easy to inspect.

## Source documentation

- [Web search tool in Foundry Agent Service](https://learn.microsoft.com/azure/foundry/agents/how-to/tools/web-search)
- [Use a Microsoft Fabric data agent with Foundry Agent Service](https://learn.microsoft.com/azure/foundry/agents/how-to/tools/fabric)
- [Build a workflow in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/agents/concepts/workflow)
- [Set up tracing in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup)
