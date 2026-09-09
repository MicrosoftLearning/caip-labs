package com.caldova.inventory;

import java.util.List;

import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

@Repository
public class InventoryRepository {

    private final JdbcClient jdbcClient;

    public InventoryRepository(JdbcClient jdbcClient) {
        this.jdbcClient = jdbcClient;
    }

    public List<InventoryItem> findAll() {
        return jdbcClient.sql("""
                SELECT id, sku, name, quantity
                FROM inventory_items
                ORDER BY sku
                """)
                .query(InventoryItem.class)
                .list();
    }

    public InventoryItem create(CreateInventoryItem request) {
        return jdbcClient.sql("""
                INSERT INTO inventory_items (sku, name, quantity)
                VALUES (:sku, :name, :quantity)
                RETURNING id, sku, name, quantity
                """)
                .param("sku", request.sku())
                .param("name", request.name())
                .param("quantity", request.quantity())
                .query(InventoryItem.class)
                .single();
    }
}
