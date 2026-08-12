---
lab:
    title: 'Build the Web IQ lab foundation'
    description: 'Create the Zava Retail lakehouse, load retail data, and publish a Fabric data agent.'
    level: 300
    duration: 45
    islab: true
    primarytopics:
        - Microsoft Fabric
        - Fabric data agent
---

# Build the Web IQ lab foundation

In this exercise, you prepare the internal-data side of the Zava Retail solution. You create a Fabric workspace and lakehouse, load synthetic retail data with a notebook, and publish a Fabric data agent that answers inventory questions in natural language.

This exercise should take approximately **45** minutes to complete.

> [!NOTE]
> Fabric data agents require a paid F2 or higher Fabric capacity or Power BI Premium P1 or higher. Your tenant administrator must also enable the required cross-geo AI processing settings.

## Prerequisites

To complete this exercise, you need:

- Access to [Microsoft Fabric](https://app.fabric.microsoft.com) with permission to create workspace items.
- A workspace assigned to a supported Fabric capacity.
- Permission to create and publish a Fabric data agent.
- The files in this lab's `Labfiles` folder.

## Create a Fabric workspace

1. Open [Microsoft Fabric](https://app.fabric.microsoft.com) and sign in.
1. In the navigation pane, select **Workspaces**, and then select **New workspace**.
1. Enter `Web IQ - Zava Retail` followed by your initials to make the name unique.
1. Expand **Advanced**, and assign the workspace to a supported Fabric capacity.
1. Select **Apply**.

## Create the Zava lakehouse

1. Open your new workspace, and then select **New item**.
1. Search for and select **Lakehouse**.
1. Enter `ZavaRetailLakehouse` for the name.
1. Leave **Lakehouse schemas** selected, and then select **Create**.
1. In the lakehouse Explorer, confirm that **Tables** and **Files** appear.

## Upload the retail data

1. In the lakehouse Explorer, select the ellipsis next to **Files**, and then select **New subfolder**.
1. Name the folder `zava-data`.
1. Select the ellipsis next to `zava-data`, and then select **Upload** > **Upload files**.
1. Upload `products.csv`, `inventory.csv`, and `carrier_routes.csv` from `Labfiles/data`.
1. Confirm that all three files appear in the folder.

## Load the Delta tables

1. Return to the workspace, select **Import** > **Notebook** > **From this computer**, and import `Labfiles/notebooks/load-zava-retail-data.ipynb`.
1. Open the notebook, and select **Add lakehouse** in the Explorer pane.
1. Select **Existing lakehouse**, choose `ZavaRetailLakehouse`, and select **Add**.
1. Confirm that the lakehouse is marked as the default lakehouse.
1. Select **Run all**, and wait for the Spark session and all cells to finish.
1. In the lakehouse Explorer, refresh **Tables** and confirm that `products`, `inventory`, `carrier_routes`, and `stock_status` appear.

The final notebook output lists products in projected-stock order. Products with negative projected units have a `High` stockout risk.

## Create the Fabric data agent

1. Return to the workspace, select **New item**, and search for **Data agent**.
1. Select **Data agent**, enter `Zava Inventory Data Agent`, and select **Create**.
1. Select **Add a data source**, choose **Lakehouse**, and select `ZavaRetailLakehouse`.
1. Add the `products`, `inventory`, `carrier_routes`, and `stock_status` tables.
1. In **Data agent instructions**, enter:

    ```text
    Answer questions about Zava Retail products, inventory, stockout risk, and carrier routes.
    Use stock_status for stockout questions. projected_units equals on_hand_units plus
    inbound_units minus expected_weekly_sales. A negative projected_units value means
    high stockout risk. Do not infer causes or use information outside the selected tables.
    ```

1. Add this example question and query if the experience offers **Example queries**:

    ```text
    Question: Which products are at risk of stockout?
    Query: SELECT product_name, distribution_hub, on_hand_units, inbound_units,
    expected_weekly_sales, projected_units, stockout_risk
    FROM stock_status
    WHERE stockout_risk IN ('High', 'Medium')
    ORDER BY projected_units ASC;
    ```

## Test and publish the data agent

1. In the data-agent chat, enter `Which products are at risk of stockout?`.
1. Confirm that the response uses `stock_status` and identifies products with high or medium risk.
1. Enter `Which carriers serve the Memphis distribution hub?`.
1. Confirm that the response uses `carrier_routes` and lists the carriers.
1. Select **Publish**, provide a description such as `Initial Zava inventory agent`, and confirm the publication.
1. Record the published data-agent name and workspace name for Exercise 2.

> [!IMPORTANT]
> Foundry uses the signed-in user's identity to call the Fabric data agent. Each learner must retain access to the published data agent and its underlying lakehouse.

## Summary

In this exercise, you created the Fabric workspace and lakehouse, loaded the Zava Retail data into Delta tables, and published a Fabric data agent for governed internal-data questions.

You have successfully completed this exercise.

## Clean up

Keep these resources for the remaining exercises. After you complete the full lab, delete the Fabric workspace if you no longer need it.
