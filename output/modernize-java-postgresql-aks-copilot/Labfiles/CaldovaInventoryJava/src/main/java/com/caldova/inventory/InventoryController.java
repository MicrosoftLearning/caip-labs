package com.caldova.inventory;

import java.net.URI;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/inventory")
public class InventoryController {

    private final InventoryRepository repository;

    public InventoryController(InventoryRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<InventoryItem> getInventory() {
        return repository.findAll();
    }

    @PostMapping
    public ResponseEntity<?> createInventoryItem(@RequestBody CreateInventoryItem request) {
        if (request.sku() == null || request.sku().isBlank()
                || request.name() == null || request.name().isBlank()
                || request.quantity() < 0) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "SKU and name are required, and quantity cannot be negative."));
        }

        InventoryItem created = repository.create(request);
        return ResponseEntity.created(URI.create("/inventory/" + created.id())).body(created);
    }
}
