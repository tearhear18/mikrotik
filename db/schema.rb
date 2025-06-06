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

ActiveRecord::Schema.define(version: 2024_07_28_220200) do

  create_table "add_index_to_voucher_codes", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "agent_documents", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.bigint "agent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "sale_amount", precision: 10
    t.integer "multiplier", default: 1
    t.index ["agent_id"], name: "index_agent_documents_on_agent_id"
  end

  create_table "agent_sales", charset: "utf8mb4", force: :cascade do |t|
    t.decimal "amount", precision: 10
    t.bigint "agent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_collected", default: false
    t.index ["agent_id"], name: "index_agent_sales_on_agent_id"
  end

  create_table "agents", charset: "utf8mb4", force: :cascade do |t|
    t.string "prefix"
    t.string "name"
    t.integer "total_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "multiplier"
    t.integer "total_sales"
    t.json "time_config"
    t.string "server"
  end

  create_table "login_vouchers", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "login_time"
    t.string "voucher_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_imported", default: false
    t.bigint "agent_id"
    t.boolean "is_collected", default: false
    t.decimal "price", precision: 8, scale: 2
    t.index ["agent_id"], name: "index_login_vouchers_on_agent_id"
    t.index ["voucher_code"], name: "index_login_vouchers_on_voucher_code", unique: true
  end

  create_table "raw_vouchers", charset: "utf8mb4", force: :cascade do |t|
    t.string "tag"
    t.string "code"
    t.string "limit_uptime"
    t.string "uptime"
    t.string "profile"
    t.boolean "status", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "routers", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "ip_address"
    t.string "username"
    t.string "password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vouchers", charset: "utf8mb4", force: :cascade do |t|
    t.string "tag"
    t.string "code"
    t.string "limit_uptime"
    t.string "uptime"
    t.string "profile"
    t.boolean "status", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "agent_id"
    t.string "time_set"
    t.boolean "in_mikrotik", default: true
    t.bigint "agent_document_id"
    t.index ["agent_document_id"], name: "index_vouchers_on_agent_document_id"
    t.index ["agent_id"], name: "index_vouchers_on_agent_id"
    t.index ["code"], name: "index_vouchers_on_code", unique: true
  end

end
