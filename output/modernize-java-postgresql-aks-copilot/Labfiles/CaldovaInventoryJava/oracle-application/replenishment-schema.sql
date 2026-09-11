CREATE TABLE replenishment_rules
(
    rule_id NUMBER(19) NOT NULL,
    sku VARCHAR2(32 CHAR) NOT NULL,
    minimum_stock NUMBER(10) DEFAULT 0 NOT NULL,
    target_stock NUMBER(10) NOT NULL,
    effective_from DATE DEFAULT SYSDATE NOT NULL,
    active_flag CHAR(1 CHAR) DEFAULT 'Y' NOT NULL,
    CONSTRAINT pk_replenishment_rules PRIMARY KEY (rule_id),
    CONSTRAINT uq_replenishment_rules_sku UNIQUE (sku),
    CONSTRAINT ck_replenishment_minimum CHECK (minimum_stock >= 0),
    CONSTRAINT ck_replenishment_target CHECK (target_stock >= minimum_stock),
    CONSTRAINT ck_replenishment_active CHECK (active_flag IN ('Y', 'N'))
);

CREATE SEQUENCE replenishment_rules_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE OR REPLACE TRIGGER replenishment_rules_bir
BEFORE INSERT ON replenishment_rules
FOR EACH ROW
WHEN (NEW.rule_id IS NULL)
BEGIN
    SELECT replenishment_rules_seq.NEXTVAL
    INTO :NEW.rule_id
    FROM dual;
END;
/

INSERT INTO replenishment_rules
    (rule_id, sku, minimum_stock, target_stock, active_flag)
VALUES
    (replenishment_rules_seq.NEXTVAL, 'CAL-100', 10, 30, 'Y');

INSERT INTO replenishment_rules
    (rule_id, sku, minimum_stock, target_stock, active_flag)
VALUES
    (replenishment_rules_seq.NEXTVAL, 'CAL-200', 8, 24, 'Y');

COMMIT;