# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151003181102) do

  create_table "matchings", force: :cascade do |t|
    t.integer  "top_player",      limit: 4
    t.integer  "bottom_player",   limit: 4
    t.datetime "top_datetime"
    t.datetime "bottom_datetime"
    t.datetime "agreed_datetime"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",            limit: 64,  null: false
    t.string   "steam_id",        limit: 64,  null: false
    t.string   "email",           limit: 64,  null: false
    t.string   "team_name",       limit: 64,  null: false
    t.integer  "mmr",             limit: 4,   null: false
    t.string   "password_digest", limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "team_order",      limit: 4
    t.string   "display_name",    limit: 64
  end

end
