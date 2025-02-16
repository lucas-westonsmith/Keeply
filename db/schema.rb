# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_02_06_162530) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "item_lists", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_lists_on_item_id"
    t.index ["list_id"], name: "index_item_lists_on_list_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.string "condition"
    t.string "category"
    t.bigint "user_id", null: false
    t.date "purchase_date"
    t.date "warranty_expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "issuer"
    t.boolean "for_sale", default: false
    t.integer "buyer_id"
    t.decimal "selling_price"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "list_users", force: :cascade do |t|
    t.string "role"
    t.bigint "user_id", null: false
    t.bigint "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_users_on_list_id"
    t.index ["user_id"], name: "index_list_users_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "picture"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "super_list_id"
    t.index ["super_list_id"], name: "index_lists_on_super_list_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "loyalty_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "card_number"
    t.string "barcode_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_number"], name: "index_loyalty_cards_on_card_number", unique: true
    t.index ["user_id"], name: "index_loyalty_cards_on_user_id"
  end

  create_table "super_lists", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.index ["user_id"], name: "index_super_lists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "avatar"
    t.string "country"
    t.string "phone_number"
    t.string "preferred_language"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "item_lists", "items"
  add_foreign_key "item_lists", "lists"
  add_foreign_key "items", "users"
  add_foreign_key "list_users", "lists"
  add_foreign_key "list_users", "users"
  add_foreign_key "lists", "super_lists"
  add_foreign_key "lists", "users"
  add_foreign_key "loyalty_cards", "users"
  add_foreign_key "super_lists", "users"
end
