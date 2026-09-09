package com.caldova.inventory;

public record InventoryItem(long id, String sku, String name, int quantity) {
}
