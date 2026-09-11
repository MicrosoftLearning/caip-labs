CREATE OR REPLACE PACKAGE replenishment_api AS
    FUNCTION recommended_order_quantity
    (
        p_sku IN VARCHAR2,
        p_on_hand IN NUMBER
    ) RETURN NUMBER;
END replenishment_api;
/

CREATE OR REPLACE PACKAGE BODY replenishment_api AS
    FUNCTION recommended_order_quantity
    (
        p_sku IN VARCHAR2,
        p_on_hand IN NUMBER
    ) RETURN NUMBER
    IS
        v_target_stock NUMBER;
        v_active_flag CHAR(1);
    BEGIN
        SELECT target_stock, active_flag
        INTO v_target_stock, v_active_flag
        FROM replenishment_rules
        WHERE UPPER(sku) = UPPER(p_sku)
          AND effective_from <= SYSDATE;

        IF v_active_flag = 'N' THEN
            RETURN 0;
        END IF;

        RETURN GREATEST(v_target_stock - NVL(p_on_hand, 0), 0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END recommended_order_quantity;
END replenishment_api;
/