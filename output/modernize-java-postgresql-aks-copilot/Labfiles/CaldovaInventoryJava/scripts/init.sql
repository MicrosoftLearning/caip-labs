CREATE TABLE IF NOT EXISTS inventory_items
(
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku varchar(32) NOT NULL UNIQUE,
    name varchar(100) NOT NULL,
    quantity integer NOT NULL CHECK (quantity >= 0)
);

TRUNCATE TABLE inventory_items RESTART IDENTITY;

INSERT INTO inventory_items (sku, name, quantity)
VALUES
    ('CAL-100', 'Pressure controller', 12),
    ('CAL-200', 'Industrial gateway', 7),
    ('CAL-300', 'Safety relay', 25);
