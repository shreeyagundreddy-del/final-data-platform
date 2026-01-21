CREATE TABLE IF NOT EXISTS dim.payment_type_dim (
  payment_type_sk   BIGINT IDENTITY(1,1),
  payment_type_id   INTEGER NOT NULL,
  payment_type_name VARCHAR(50) NOT NULL,
  description       VARCHAR(200),

  record_source     VARCHAR(100) DEFAULT 'TLC data dictionary',
  created_at        TIMESTAMP DEFAULT GETDATE(),
  updated_at        TIMESTAMP DEFAULT GETDATE(),
  CONSTRAINT pk_payment_type_dim PRIMARY KEY (payment_type_sk)
)
DISTSTYLE ALL
SORTKEY (payment_type_id);

INSERT INTO dim.payment_type_dim (payment_type_id, payment_type_name, description) VALUES
  (1, 'Credit Card', 'Payment made by credit card'),
  (2, 'Cash', 'Payment made in cash'),
  (3, 'No Charge', 'No charge trip'),
  (4, 'Dispute', 'Disputed transaction'),
  (5, 'Unknown', 'Unknown payment type'),
  (6, 'Voided Trip', 'Voided trip');