-- HUBS
CREATE TABLE hub_customer (
    customer_hk VARCHAR(32) NOT NULL,
    c_customer_id VARCHAR(16) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_hk)
);

CREATE TABLE hub_item (
    item_hk VARCHAR(32) NOT NULL,
    i_item_id VARCHAR(16) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (item_hk)
);

CREATE TABLE hub_store (
    store_hk VARCHAR(32) NOT NULL,
    s_store_id VARCHAR(16) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (store_hk)
);

CREATE TABLE hub_promotion (
    promotion_hk VARCHAR(32) NOT NULL,
    p_promo_id VARCHAR(16) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (promotion_hk)
);

CREATE TABLE hub_address (
    address_hk VARCHAR(32) NOT NULL,
    ca_address_id VARCHAR(16) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (address_hk)
);

CREATE TABLE hub_sales_transaction (
    sales_transaction_hk VARCHAR(32) NOT NULL,
    ss_ticket_number BIGINT NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (sales_transaction_hk)
);

CREATE TABLE hub_date (
    date_hk VARCHAR(32) NOT NULL,
    d_date DATE NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (date_hk)
);

-- LINKS
CREATE TABLE link_store_sale (
    store_sale_hk VARCHAR(32) NOT NULL,
    sales_transaction_hk VARCHAR(32) NOT NULL,
    customer_hk VARCHAR(32) NOT NULL,
    item_hk VARCHAR(32) NOT NULL,
    store_hk VARCHAR(32) NOT NULL,
    date_hk VARCHAR(32) NOT NULL,
    promotion_hk VARCHAR(32) NOT NULL, -- ghost-row for missing
    address_hk VARCHAR(32) NOT NULL, -- ghost-row for missing
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (store_sale_hk),
    FOREIGN KEY (sales_transaction_hk) REFERENCES hub_sales_transaction (sales_transaction_hk),
    FOREIGN KEY (customer_hk) REFERENCES hub_customer (customer_hk),
    FOREIGN KEY (item_hk) REFERENCES hub_item (item_hk),
    FOREIGN KEY (store_hk) REFERENCES hub_store (store_hk),
    FOREIGN KEY (date_hk) REFERENCES hub_date (date_hk),
    FOREIGN KEY (promotion_hk) REFERENCES hub_promotion (promotion_hk),
    FOREIGN KEY (address_hk) REFERENCES hub_address (address_hk)
);

CREATE TABLE link_customer_address (
    customer_address_hk VARCHAR(32) NOT NULL,
    customer_hk VARCHAR(32) NOT NULL,
    address_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_address_hk),
    FOREIGN KEY (customer_hk) REFERENCES hub_customer (customer_hk),
    FOREIGN KEY (address_hk) REFERENCES hub_address (address_hk)
);

-- SATELLITES ON HUBS
CREATE TABLE sat_customer_profile (
    customer_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    c_salutation VARCHAR(10),
    c_first_name VARCHAR(20),
    c_last_name VARCHAR(30),
    c_preferred_cust_flag CHAR(1),
    c_birth_day INTEGER,
    c_birth_month INTEGER,
    c_birth_year INTEGER,
    c_birth_country VARCHAR(20),
    c_login VARCHAR(13),
    c_email_address VARCHAR(50),
    c_first_shipto_date DATE,
    c_first_sales_date DATE,
    c_last_review_date DATE,
    PRIMARY KEY (customer_hk, load_date),
    FOREIGN KEY (customer_hk) REFERENCES hub_customer (customer_hk)
);

CREATE TABLE sat_customer_demographic (
    customer_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    cd_gender CHAR(1),
    cd_marital_status CHAR(1),
    cd_education_status VARCHAR(20),
    cd_purchase_estimate INTEGER,
    cd_credit_rating VARCHAR(10),
    cd_dep_count INTEGER,
    cd_dep_employed_count INTEGER,
    cd_dep_college_count INTEGER,
    PRIMARY KEY (customer_hk, load_date),
    FOREIGN KEY (customer_hk) REFERENCES hub_customer (customer_hk)
);

CREATE TABLE sat_customer_household (
    customer_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    hd_income_band_id INTEGER,
    hd_buy_potential VARCHAR(15),
    hd_dep_count INTEGER,
    hd_vehicle_count INTEGER,
    PRIMARY KEY (customer_hk, load_date),
    FOREIGN KEY (customer_hk) REFERENCES hub_customer (customer_hk)
);

CREATE TABLE sat_item_detail (
    item_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    i_product_name VARCHAR(50),
    i_item_desc VARCHAR(200),
    i_brand_id INTEGER,
    i_brand VARCHAR(50),
    i_class_id INTEGER,
    i_class VARCHAR(50),
    i_category_id INTEGER,
    i_category VARCHAR(50),
    i_manufact_id INTEGER,
    i_manufact VARCHAR(50),
    i_size VARCHAR(20),
    i_color VARCHAR(20),
    i_units VARCHAR(10),
    i_container VARCHAR(10),
    i_manager_id INTEGER,
    PRIMARY KEY (item_hk, load_date),
    FOREIGN KEY (item_hk) REFERENCES hub_item (item_hk)
);

CREATE TABLE sat_item_price (
    item_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    i_current_price DECIMAL(7, 2),
    i_wholesale_cost DECIMAL(7, 2),
    PRIMARY KEY (item_hk, load_date),
    FOREIGN KEY (item_hk) REFERENCES hub_item (item_hk)
);

CREATE TABLE sat_store_detail (
    store_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    s_store_name VARCHAR(50),
    s_number_employees INTEGER,
    s_floor_space INTEGER,
    s_hours VARCHAR(20),
    s_manager VARCHAR(40),
    s_market_id INTEGER,
    s_market_desc VARCHAR(100),
    s_market_manager VARCHAR(40),
    s_division_id INTEGER,
    s_division_name VARCHAR(50),
    s_company_id INTEGER,
    s_company_name VARCHAR(50),
    s_tax_percentage DECIMAL(5, 2),
    PRIMARY KEY (store_hk, load_date),
    FOREIGN KEY (store_hk) REFERENCES hub_store (store_hk)
);

CREATE TABLE sat_store_location (
    store_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    s_street_number VARCHAR(10),
    s_street_name VARCHAR(60),
    s_street_type VARCHAR(15),
    s_suite_number VARCHAR(10),
    s_city VARCHAR(60),
    s_county VARCHAR(30),
    s_state CHAR(2),
    s_zip VARCHAR(10),
    s_country VARCHAR(20),
    s_gmt_offset DECIMAL(5, 2),
    PRIMARY KEY (store_hk, load_date),
    FOREIGN KEY (store_hk) REFERENCES hub_store (store_hk)
);

CREATE TABLE sat_promotion (
    promotion_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    p_promo_name VARCHAR(50),
    p_cost DECIMAL(15, 2),
    p_response_target INTEGER,
    p_start_date DATE,
    p_end_date DATE,
    p_channel_dmail CHAR(1),
    p_channel_email CHAR(1),
    p_channel_catalog CHAR(1),
    p_channel_tv CHAR(1),
    p_channel_radio CHAR(1),
    p_channel_press CHAR(1),
    p_channel_event CHAR(1),
    p_channel_demo CHAR(1),
    p_channel_details VARCHAR(100),
    p_purpose VARCHAR(15),
    p_discount_active CHAR(1),
    PRIMARY KEY (promotion_hk, load_date),
    FOREIGN KEY (promotion_hk) REFERENCES hub_promotion (promotion_hk)
);

CREATE TABLE sat_address (
    address_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    ca_street_number VARCHAR(10),
    ca_street_name VARCHAR(60),
    ca_street_type VARCHAR(15),
    ca_suite_number VARCHAR(10),
    ca_city VARCHAR(60),
    ca_county VARCHAR(30),
    ca_state CHAR(2),
    ca_zip VARCHAR(10),
    ca_country VARCHAR(20),
    ca_gmt_offset DECIMAL(5, 2),
    ca_location_type VARCHAR(20),
    PRIMARY KEY (address_hk, load_date),
    FOREIGN KEY (address_hk) REFERENCES hub_address (address_hk)
);

CREATE TABLE sat_date (
    date_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    d_month_seq INTEGER,
    d_week_seq INTEGER,
    d_quarter_seq INTEGER,
    d_year INTEGER,
    d_dow INTEGER,
    d_moy INTEGER,
    d_dom INTEGER,
    d_qoy INTEGER,
    d_fy_year INTEGER,
    d_fy_quarter_seq INTEGER,
    d_fy_week_seq INTEGER,
    d_day_name VARCHAR(9),
    d_quarter_name VARCHAR(6),
    d_holiday CHAR(1),
    d_weekend CHAR(1),
    d_following_holiday CHAR(1),
    PRIMARY KEY (date_hk, load_date),
    FOREIGN KEY (date_hk) REFERENCES hub_date (date_hk)
);

-- SATELLITES ON LINKS
CREATE TABLE sat_store_sale_measures (
    store_sale_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    ss_sold_time TIME,
    ss_quantity INTEGER,
    ss_wholesale_cost DECIMAL(7, 2),
    ss_list_price DECIMAL(7, 2),
    ss_sales_price DECIMAL(7, 2),
    ss_ext_discount_amt DECIMAL(7, 2),
    ss_ext_sales_price DECIMAL(7, 2),
    ss_ext_wholesale_cost DECIMAL(7, 2),
    ss_ext_list_price DECIMAL(7, 2),
    ss_ext_tax DECIMAL(7, 2),
    ss_coupon_amt DECIMAL(7, 2),
    ss_net_paid DECIMAL(7, 2),
    ss_net_paid_inc_tax DECIMAL(7, 2),
    ss_net_profit DECIMAL(7, 2),
    PRIMARY KEY (store_sale_hk, load_date),
    FOREIGN KEY (store_sale_hk) REFERENCES link_store_sale (store_sale_hk)
);

CREATE TABLE sat_customer_address_effectivity (
    customer_address_hk VARCHAR(32) NOT NULL,
    load_date TIMESTAMP NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    hash_diff VARCHAR(32) NOT NULL,
    is_current CHAR(1) NOT NULL, -- 'Y' / 'N'
    PRIMARY KEY (customer_address_hk, load_date),
    FOREIGN KEY (customer_address_hk) REFERENCES link_customer_address (customer_address_hk)
);