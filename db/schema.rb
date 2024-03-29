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

ActiveRecord::Schema.define(version: 2022_05_09_144231) do

  create_table "comments", force: :cascade do |t|
    t.string "author", default: "", null: false
    t.text "comment", default: "", null: false
    t.integer "UpVotes", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "id_submission", default: 0, null: false
    t.integer "id_comment_father", default: 0, null: false
    t.integer "submission_id"
    t.integer "comment_id"
    t.index ["comment_id"], name: "index_comments_on_comment_id"
    t.index ["submission_id"], name: "index_comments_on_submission_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "UpVotes", default: 0
    t.string "author_username", default: "", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "about"
    t.integer "karma", default: 0
    t.text "LikedSubmissions"
    t.text "LikedComments"
    t.string "auth_token"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "comments"
  add_foreign_key "comments", "submissions"
end
