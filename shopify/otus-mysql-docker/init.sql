CREATE DATABASE IF NOT EXISTS otus;
USE otus;

CREATE TABLE IF NOT EXISTS Apparel (
    handle varchar(100),
    title varchar(100),
    html text,
    vendor varchar(30),
    type varchar(30),
    tags varchar(256),
    published varchar(5),
    op1name varchar(30),
    op1value varchar(100),
    op2name varchar(30),
    op2value varchar(100),
    op3name varchar(30),
    op3value varchar(100),
    v_sku varchar(100),
    v_grams varchar(10),
    v_inv_tracker varchar(20),
    v_inv_qty varchar(10),
    v_inv_policy varchar(20),
    v_fulfillment_service varchar(20),
    v_price varchar(12),
    v_compare_at_price varchar(12),
    v_req_shipping varchar(5),
    v_taxable varchar(5),
    v_barcode varchar(30),
    img_src text,
    img_alt text,
    gift_card varchar(5),
    seo_title varchar(10),
    seo_description text,
    gs_category text,
    gs_gender varchar(10),
    gs_age_group varchar(10),
    gs_mpn varchar(30),
    gs_adwords_grouping text,
    gs_adwords_labels text,
    gs_condition varchar(20),
    gs_custom_product varchar(5),
    gs_custom_label_0 text,
    gs_custom_label_1 text,
    gs_custom_label_2 text,
    gs_custom_label_3 text,
    gs_custom_label_4 text,
    v_image text,
    v_weight_unit varchar(10)
);

CREATE TABLE IF NOT EXISTS Bicycles (
    handle varchar(100),
    title varchar(100),
    html text,
    vendor varchar(30),
    type varchar(30),
    tags varchar(256),
    published varchar(5),
    op1name varchar(30),
    op1value varchar(100),
    op2name varchar(30),
    op2value varchar(100),
    op3name varchar(30),
    op3value varchar(100),
    v_sku varchar(100),
    v_grams varchar(10),
    v_inv_tracker varchar(20),
    v_inv_qty varchar(10),
    v_inv_policy varchar(20),
    v_fulfillment_service varchar(20),
    v_price varchar(12),
    v_compare_at_price varchar(12),
    v_req_shipping varchar(5),
    v_taxable varchar(5),
    v_barcode varchar(30),
    img_src text,
    img_alt text,
    gift_card varchar(5),
    seo_title varchar(10),
    seo_description text,
    gs_category text,
    gs_gender varchar(10),
    gs_age_group varchar(10),
    gs_mpn varchar(30),
    gs_adwords_grouping text,
    gs_adwords_labels text,
    gs_condition varchar(20),
    gs_custom_product varchar(5),
    gs_custom_label_0 text,
    gs_custom_label_1 text,
    gs_custom_label_2 text,
    gs_custom_label_3 text,
    gs_custom_label_4 text,
    v_image text,
    v_weight_unit varchar(10)
);

CREATE TABLE IF NOT EXISTS Fashion (
    handle varchar(100),
    title varchar(100),
    html text,
    vendor varchar(30),
    type varchar(30),
    tags varchar(256),
    published varchar(5),
    op1name varchar(30),
    op1value varchar(100),
    op2name varchar(30),
    op2value varchar(100),
    op3name varchar(30),
    op3value varchar(100),
    v_sku varchar(100),
    v_grams varchar(10),
    v_inv_tracker varchar(20),
    v_inv_qty varchar(10),
    v_inv_policy varchar(20),
    v_fulfillment_service varchar(20),
    v_price varchar(12),
    v_compare_at_price varchar(12),
    v_req_shipping varchar(5),
    v_taxable varchar(5),
    v_barcode varchar(30),
    img_src text,
    img_alt text,
    gift_card varchar(5),
    seo_title varchar(10),
    seo_description text,
    gs_category text,
    gs_gender varchar(10),
    gs_age_group varchar(10),
    gs_mpn varchar(30),
    gs_adwords_grouping text,
    gs_adwords_labels text,
    gs_condition varchar(20),
    gs_custom_product varchar(5),
    gs_custom_label_0 text,
    gs_custom_label_1 text,
    gs_custom_label_2 text,
    gs_custom_label_3 text,
    gs_custom_label_4 text,
    v_image text,
    v_weight_unit varchar(10)
);

CREATE TABLE IF NOT EXISTS jewelry (
    handle varchar(100),
    title varchar(100),
    html text,
    vendor varchar(30),
    type varchar(30),
    tags varchar(256),
    published varchar(5),
    op1name varchar(30),
    op1value varchar(100),
    op2name varchar(30),
    op2value varchar(100),
    op3name varchar(30),
    op3value varchar(100),
    v_sku varchar(100),
    v_grams varchar(10),
    v_inv_tracker varchar(20),
    v_inv_qty varchar(10),
    v_inv_policy varchar(20),
    v_fulfillment_service varchar(20),
    v_price varchar(12),
    v_compare_at_price varchar(12),
    v_req_shipping varchar(5),
    v_taxable varchar(5),
    v_barcode varchar(30),
    img_src text,
    img_alt text,
    gift_card varchar(5),
    seo_title varchar(10),
    seo_description text,
    gs_category text,
    gs_gender varchar(10),
    gs_age_group varchar(10),
    gs_mpn varchar(30),
    gs_adwords_grouping text,
    gs_adwords_labels text,
    gs_condition varchar(20),
    gs_custom_product varchar(5),
    gs_custom_label_0 text,
    gs_custom_label_1 text,
    gs_custom_label_2 text,
    gs_custom_label_3 text,
    gs_custom_label_4 text,
    v_image text,
    v_weight_unit varchar(10)
);

CREATE TABLE IF NOT EXISTS SnowDevil (
    handle varchar(100),
    title varchar(100),
    html text,
    vendor varchar(30),
    type varchar(30),
    tags varchar(256),
    published varchar(5),
    op1name varchar(30),
    op1value varchar(100),
    op2name varchar(30),
    op2value varchar(100),
    op3name varchar(30),
    op3value varchar(100),
    v_sku varchar(100),
    v_grams varchar(10),
    v_inv_tracker varchar(20),
    v_inv_qty varchar(10),
    v_inv_policy varchar(20),
    v_fulfillment_service varchar(20),
    v_price varchar(12),
    v_compare_at_price varchar(12),
    v_req_shipping varchar(5),
    v_taxable varchar(5),
    v_barcode varchar(30),
    img_src text,
    img_alt text,
    gift_card varchar(5),
    seo_title varchar(10),
    seo_description text,
    gs_category text,
    gs_gender varchar(10),
    gs_age_group varchar(10),
    gs_mpn varchar(30),
    gs_adwords_grouping text,
    gs_adwords_labels text,
    gs_condition varchar(20),
    gs_custom_product varchar(5),
    gs_custom_label_0 text,
    gs_custom_label_1 text,
    gs_custom_label_2 text,
    gs_custom_label_3 text,
    gs_custom_label_4 text,
    v_image text,
    v_weight_unit varchar(10)
);