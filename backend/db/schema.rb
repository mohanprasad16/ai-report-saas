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

ActiveRecord::Schema[7.2].define(version: 2026_02_11_042407) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "ai_reports", force: :cascade do |t|
    t.text "prompt"
    t.text "response"
    t.string "model"
    t.integer "prompt_tokens"
    t.integer "completion_tokens"
    t.integer "total_tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "churn_metrics", force: :cascade do |t|
    t.date "month"
    t.float "churn_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region"
  end

  create_table "knowledge_base_articles", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.vector "embedding", limit: 3072
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "marketing_spends", force: :cascade do |t|
    t.date "month"
    t.string "region"
    t.integer "spend_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "revenues", force: :cascade do |t|
    t.date "month"
    t.string "region"
    t.integer "total_revenue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
