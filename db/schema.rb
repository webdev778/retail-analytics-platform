# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161011124208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "seller_id"
    t.string   "mws_auth_token"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", using: :btree
  end

  create_table "fulfillment_inbound_shipments", force: :cascade do |t|
    t.integer  "marketplace_id"
    t.string   "shipment_id"
    t.datetime "external_date_created"
    t.decimal  "price",                 precision: 10, scale: 2
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "total_received_units"
    t.index ["marketplace_id"], name: "index_fulfillment_inbound_shipments_on_marketplace_id", using: :btree
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "msku"
    t.decimal  "price",          precision: 10, scale: 2
    t.date     "date_purchased"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["user_id"], name: "index_inventories_on_user_id", using: :btree
  end

  create_table "inventory_data_uploads", force: :cascade do |t|
    t.string   "file_for_import_file_name"
    t.string   "file_for_import_content_type"
    t.integer  "file_for_import_file_size"
    t.datetime "file_for_import_updated_at"
    t.string   "description"
    t.string   "status"
    t.datetime "finished_at"
    t.integer  "imported_new"
    t.integer  "already_exist"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "index_inventory_data_uploads_on_user_id", using: :btree
  end

  create_table "marketplaces", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.string   "external_marketplace_id"
    t.string   "aws_access_key_id"
    t.string   "secret_key"
    t.string   "status"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "get_received_inventory_finished"
    t.index ["account_id"], name: "index_marketplaces_on_account_id", using: :btree
    t.index ["user_id"], name: "index_marketplaces_on_user_id", using: :btree
  end

  create_table "received_inventories", force: :cascade do |t|
    t.integer  "marketplace_id"
    t.datetime "received_date"
    t.string   "fnsku"
    t.string   "sku"
    t.string   "product_name"
    t.integer  "quantity"
    t.string   "fba_shipment_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.decimal  "price_per_unit",  precision: 10, scale: 2
    t.decimal  "price_total",     precision: 10, scale: 2
    t.index ["marketplace_id"], name: "index_received_inventories_on_marketplace_id", using: :btree
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "marketplace_id"
    t.datetime "date_time"
    t.string   "settlement_id"
    t.string   "type"
    t.string   "order_id"
    t.string   "sku"
    t.string   "quantity"
    t.string   "product_sales"
    t.string   "shipping_credits"
    t.string   "gift_wrap_credits"
    t.string   "promotional_rebates"
    t.string   "selling_fees"
    t.string   "fba_fees"
    t.string   "other_transaction_fees"
    t.string   "other"
    t.string   "total"
    t.decimal  "shipping_price",          precision: 10, scale: 2
    t.decimal  "shipping_tax",            precision: 10, scale: 2
    t.decimal  "item_promotion_discount", precision: 10, scale: 2
    t.decimal  "ship_promotion_discount", precision: 10, scale: 2
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["marketplace_id"], name: "index_transactions_on_marketplace_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
