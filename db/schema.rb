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

ActiveRecord::Schema.define(version: 2021_10_17_034333) do

  create_table "asset_files", force: :cascade do |t|
    t.integer "content_id"
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_asset_files_on_content_id"
  end

  create_table "attachment_files", force: :cascade do |t|
    t.integer "content_id"
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_attachment_files_on_content_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "lesson_id"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_attendances_on_lesson_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "display_order"
    t.string "display_title"
    t.integer "target_id"
    t.string "target_type", default: "web"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id", "display_title"], name: "index_bookmarks_on_manager_id_and_display_title", unique: true
    t.index ["target_id"], name: "index_bookmarks_on_target_id"
  end

  create_table "content_members", force: :cascade do |t|
    t.integer "content_id"
    t.integer "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "content_id"], name: "index_content_members_on_user_id_and_content_id", unique: true
  end

  create_table "contents", force: :cascade do |t|
    t.string "category"
    t.string "folder_name"
    t.string "title"
    t.text "condition"
    t.text "overview"
    t.string "status", default: "open"
    t.string "as_category", default: "text"
    t.text "as_overview"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_name"], name: "index_contents_on_folder_name", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.boolean "enabled", default: true
    t.string "sourced_id"
    t.integer "term_id"
    t.text "image_data"
    t.string "title"
    t.text "overview"
    t.integer "weekday", default: 9
    t.integer "period", default: 0
    t.string "status", default: "draft"
    t.integer "groups_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_courses_on_enabled"
    t.index ["sourced_id"], name: "index_courses_on_sourced_id", unique: true
    t.index ["term_id"], name: "index_courses_on_term_id"
  end

  create_table "devices", force: :cascade do |t|
    t.integer "manager_id"
    t.string "title"
    t.string "registration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_devices_on_manager_id"
    t.index ["registration_id"], name: "index_devices_on_registration_id", unique: true
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "course_id"
    t.integer "user_id"
    t.string "role"
    t.integer "group_index", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sourced_id"
    t.index ["group_index"], name: "index_enrollments_on_group_index"
    t.index ["sourced_id"], name: "index_enrollments_on_sourced_id", unique: true
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
  end

  create_table "goals", force: :cascade do |t|
    t.integer "course_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_goals_on_course_id"
  end

  create_table "goals_objectives", force: :cascade do |t|
    t.integer "lesson_id"
    t.integer "goal_id"
    t.integer "objective_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goal_id"], name: "index_goals_objectives_on_goal_id"
    t.index ["lesson_id"], name: "index_goals_objectives_on_lesson_id"
    t.index ["objective_id", "goal_id"], name: "index_goals_objectives_on_objective_id_and_goal_id", unique: true
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "evaluator_id"
    t.integer "content_id"
    t.integer "course_id"
    t.integer "display_order"
    t.string "status"
    t.datetime "attendance_start_at"
    t.datetime "attendance_end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id", "course_id"], name: "index_lessons_on_content_id_and_course_id", unique: true
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "controller"
    t.string "action"
    t.json "params"
    t.string "src_ip"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nav_section"
    t.string "nav_controller"
    t.integer "nav_id"
    t.integer "content_id"
    t.integer "page_num"
    t.integer "max_page_num"
    t.index ["action"], name: "index_logs_on_action"
    t.index ["content_id"], name: "index_logs_on_content_id"
    t.index ["controller"], name: "index_logs_on_controller"
    t.index ["nav_id"], name: "index_logs_on_nav_id"
    t.index ["page_num"], name: "index_logs_on_page_num"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "content_id"
    t.integer "objective_id"
    t.integer "counter", default: 0
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_message_templates_on_content_id"
    t.index ["manager_id"], name: "index_message_templates_on_manager_id"
    t.index ["objective_id"], name: "index_message_templates_on_objective_id"
  end

  create_table "note_indices", force: :cascade do |t|
    t.integer "note_id"
    t.integer "item_id"
    t.string "item_type", default: "Snippet"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "item_type", "note_id"], name: "index_note_indices_on_item_id_and_item_type_and_note_id", unique: true
    t.index ["note_id"], name: "index_note_indices_on_note_id"
  end

  create_table "note_stars", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "note_id"
    t.boolean "stared", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id", "note_id"], name: "index_note_stars_on_manager_id_and_note_id", unique: true
    t.index ["note_id"], name: "index_note_stars_on_note_id"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "course_id", default: 0
    t.integer "original_ws_id", default: 0
    t.string "title"
    t.text "overview"
    t.string "category", default: "private"
    t.string "status", default: "draft"
    t.integer "stars_count", default: 0
    t.integer "peer_reviews_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_notes_on_category"
    t.index ["course_id"], name: "index_notes_on_course_id"
    t.index ["manager_id"], name: "index_notes_on_manager_id"
    t.index ["original_ws_id"], name: "index_notes_on_original_ws_id"
  end

  create_table "notices", force: :cascade do |t|
    t.integer "course_id"
    t.integer "manager_id"
    t.string "status", default: "open"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_notices_on_course_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.integer "content_id"
    t.string "title"
    t.text "criterion"
    t.integer "allocation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_objectives_on_content_id"
  end

  create_table "outcome_files", force: :cascade do |t|
    t.integer "outcome_id"
    t.text "upload_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outcome_id"], name: "index_outcome_files_on_outcome_id"
  end

  create_table "outcome_messages", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "outcome_id"
    t.text "message"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_outcome_messages_on_manager_id"
    t.index ["outcome_id"], name: "index_outcome_messages_on_outcome_id"
  end

  create_table "outcome_texts", force: :cascade do |t|
    t.integer "outcome_id"
    t.text "entry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outcome_id"], name: "index_outcome_texts_on_outcome_id"
  end

  create_table "outcomes", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "course_id"
    t.integer "lesson_id"
    t.string "folder_name"
    t.string "status", default: "draft"
    t.integer "score"
    t.boolean "checked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_outcomes_on_course_id"
    t.index ["lesson_id"], name: "index_outcomes_on_lesson_id"
    t.index ["manager_id", "lesson_id"], name: "index_outcomes_on_manager_id_and_lesson_id", unique: true
  end

  create_table "outcomes_objectives", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "objective_id"
    t.integer "self_achievement"
    t.integer "eval_achievement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outcome_id", "objective_id"], name: "index_outcomes_objectives_on_outcome_id_and_objective_id", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.integer "content_id"
    t.integer "display_order"
    t.string "category", default: "file"
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_pages_on_content_id"
  end

  create_table "signins", force: :cascade do |t|
    t.integer "user_id"
    t.string "src_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_signins_on_user_id"
  end

  create_table "snippets", force: :cascade do |t|
    t.integer "manager_id"
    t.string "category", default: "text"
    t.text "description"
    t.string "source_type", default: "direct"
    t.integer "source_id"
    t.text "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_snippets_on_manager_id"
  end

  create_table "stickies", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "content_id"
    t.integer "course_id"
    t.integer "target_id"
    t.string "target_type", default: "Page"
    t.integer "stars_count", default: 0
    t.string "category", default: "private"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_stickies_on_content_id"
    t.index ["course_id"], name: "index_stickies_on_course_id"
    t.index ["target_id"], name: "index_stickies_on_target_id"
  end

  create_table "sticky_stars", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "sticky_id"
    t.boolean "stared", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id", "sticky_id"], name: "index_sticky_stars_on_manager_id_and_sticky_id", unique: true
    t.index ["sticky_id"], name: "index_sticky_stars_on_sticky_id"
  end

  create_table "terms", force: :cascade do |t|
    t.string "sourced_id"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sourced_id"], name: "index_terms_on_sourced_id", unique: true
    t.index ["title"], name: "index_terms_on_title", unique: true
  end

  create_table "user_actions", force: :cascade do |t|
    t.integer "user_id"
    t.string "src_ip"
    t.string "category"
    t.integer "course_id"
    t.integer "lesson_id"
    t.integer "content_id"
    t.integer "page_id"
    t.integer "sticky_id"
    t.integer "sticky_star_id"
    t.integer "snippet_id"
    t.integer "outcome_id"
    t.integer "outcome_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_user_actions_on_category"
    t.index ["user_id"], name: "index_user_actions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "signin_name"
    t.string "authentication", default: "local"
    t.string "hashed_password"
    t.string "salt"
    t.string "token"
    t.string "role", default: "user"
    t.string "family_name"
    t.string "given_name"
    t.string "phonetic_family_name"
    t.string "phonetic_given_name"
    t.text "image_data"
    t.string "web_url"
    t.text "description"
    t.integer "default_note_id", default: 0
    t.datetime "last_signin_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sourced_id"
    t.index ["role"], name: "index_users_on_role"
    t.index ["signin_name"], name: "index_users_on_signin_name", unique: true
    t.index ["sourced_id"], name: "index_users_on_sourced_id", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  create_table "web_pages", force: :cascade do |t|
    t.text "url"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
