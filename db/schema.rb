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

ActiveRecord::Schema[7.1].define(version: 2024_10_01_020235) do
  create_table "card_charges", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id"
    t.integer "card_id"
    t.index ["card_id"], name: "index_card_charges_on_card_id"
    t.index ["category_id"], name: "index_card_charges_on_category_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.string "account_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "vendor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["vendor_id"], name: "index_categorizations_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_vendors_on_category_id"
  end

  add_foreign_key "card_charges", "cards"
  add_foreign_key "card_charges", "categories"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "vendors"
  add_foreign_key "vendors", "categories"
end
