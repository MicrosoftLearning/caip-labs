DROP SCHEMA IF EXISTS replenishment CASCADE;
CREATE SCHEMA replenishment;

CREATE TABLE replenishment.replenishment_rules
(
    rule_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku varchar(32) NOT NULL UNIQUE,
    minimum_stock integer DEFAULT 0 NOT NULL CHECK (minimum_stock >= 0),
    target_stock integer NOT NULL CHECK (target_stock >= minimum_stock),
    effective_from timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true NOT NULL
);

CREATE OR REPLACE FUNCTION replenishment.recommended_order_quantity(
    requested_sku varchar,
    on_hand integer
)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT CASE
        WHEN active THEN GREATEST(target_stock - COALESCE(on_hand, 0), 0)
        ELSE 0
    END
    FROM replenishment.replenishment_rules
    WHERE upper(sku) = upper(requested_sku)
      AND effective_from <= CURRENT_TIMESTAMP
    UNION ALL
    SELECT 0
    WHERE NOT EXISTS (
        SELECT 1
        FROM replenishment.replenishment_rules
        WHERE upper(sku) = upper(requested_sku)
          AND effective_from <= CURRENT_TIMESTAMP
    )
    LIMIT 1;
$$;

INSERT INTO replenishment.replenishment_rules
    (sku, minimum_stock, target_stock, active)
VALUES
    ('CAL-100', 10, 30, true),
    ('CAL-200', 8, 24, true);