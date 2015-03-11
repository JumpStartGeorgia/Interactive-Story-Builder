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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150311093819) do

  create_table "assets", :force => true do |t|
    t.integer  "item_id"
    t.integer  "asset_type"
    t.string   "caption",            :limit => 2000
    t.string   "source"
    t.integer  "option"
    t.string   "asset_file_name"
    t.string   "asset_content_type", :limit => 45
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.integer  "position"
    t.integer  "asset_subtype",                      :default => 0
    t.boolean  "processed",                          :default => false
    t.integer  "asset_clone_id"
    t.string   "avatar_id"
    t.integer  "story_id"
  end

  add_index "assets", ["asset_clone_id"], :name => "index_assets_on_asset_clone_id"
  add_index "assets", ["item_id", "asset_type"], :name => "index_assets_on_item_id_and_asset_type"
  add_index "assets", ["item_id", "position"], :name => "index_assets_on_item_id_and_position"
  add_index "assets", ["item_id"], :name => "index_assets_on_item_id"
  add_index "assets", ["processed"], :name => "index_assets_on_processed"

  create_table "author_translations", :force => true do |t|
    t.integer  "author_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
    t.text     "about"
    t.string   "permalink"
  end

  add_index "author_translations", ["author_id"], :name => "index_author_translations_on_author_id"
  add_index "author_translations", ["locale"], :name => "index_author_translations_on_locale"
  add_index "author_translations", ["name"], :name => "index_author_translations_on_name"
  add_index "author_translations", ["permalink"], :name => "index_author_translations_on_permalink"

  create_table "authors", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "has_published_stories", :default => false
  end

  add_index "categories", ["has_published_stories"], :name => "index_categories_on_has_published_stories"

  create_table "category_translations", :force => true do |t|
    t.integer  "category_id"
    t.string   "locale",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "name"
    t.string   "permalink"
  end

  add_index "category_translations", ["category_id"], :name => "index_category_translations_on_category_id"
  add_index "category_translations", ["locale"], :name => "index_category_translations_on_locale"
  add_index "category_translations", ["name"], :name => "index_category_translations_on_name"
  add_index "category_translations", ["permalink"], :name => "index_category_translations_on_permalink"

  create_table "content_translations", :force => true do |t|
    t.integer  "content_id"
    t.string   "locale",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "title"
    t.string   "caption"
    t.string   "sub_caption"
    t.text     "text"
  end

  add_index "content_translations", ["content_id"], :name => "index_content_translations_on_content_id"
  add_index "content_translations", ["locale"], :name => "index_content_translations_on_locale"

  create_table "contents", :force => true do |t|
    t.integer  "section_id"
    t.string   "old_title"
    t.string   "old_sub_caption"
    t.text     "old_content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_caption"
  end

  add_index "contents", ["section_id"], :name => "index_contents_on_section_id"

  create_table "embed_media", :force => true do |t|
    t.integer  "section_id"
    t.string   "old_title"
    t.string   "old_url"
    t.text     "old_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "embed_media", ["section_id"], :name => "index_embed_media_on_section_id"

  create_table "embed_medium_translations", :force => true do |t|
    t.integer  "embed_medium_id"
    t.string   "locale",          :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "title"
    t.string   "url"
    t.text     "code"
  end

  add_index "embed_medium_translations", ["embed_medium_id"], :name => "index_embed_medium_translations_on_embed_medium_id"
  add_index "embed_medium_translations", ["locale"], :name => "index_embed_medium_translations_on_locale"

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index", :length => {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "infographic_datasources", :force => true do |t|
    t.integer  "infographic_translation_id"
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "infographic_datasources", ["infographic_translation_id"], :name => "index_infographic_datasources_on_infographic_translation_id"

  create_table "infographic_translations", :force => true do |t|
    t.integer  "infographic_id"
    t.string   "locale",         :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "title"
    t.string   "caption"
    t.text     "description"
    t.string   "dataset_url"
    t.integer  "subtype"
    t.string   "dynamic_url"
    t.text     "dynamic_code"
  end

  add_index "infographic_translations", ["infographic_id"], :name => "index_infographic_translations_on_infographic_id"
  add_index "infographic_translations", ["locale"], :name => "index_infographic_translations_on_locale"

  create_table "infographics", :force => true do |t|
    t.integer  "section_id"
    t.date     "published_at"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "subtype"
    t.integer  "dynamic_width",  :limit => 2
    t.integer  "dynamic_height", :limit => 2
    t.integer  "dynamic_render", :limit => 1, :default => 1
  end

  add_index "infographics", ["section_id"], :name => "index_infographics_on_section_id"

  create_table "invitations", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "story_id"
    t.string   "to_email"
    t.integer  "to_user_id"
    t.string   "key"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.text     "message"
    t.integer  "role",                :limit => 1, :default => 0
    t.string   "translation_locales"
  end

  add_index "invitations", ["key"], :name => "index_invitations_on_key"
  add_index "invitations", ["story_id"], :name => "index_invitations_on_story_id"
  add_index "invitations", ["to_user_id"], :name => "index_invitations_on_to_user_id"

  create_table "languages", :force => true do |t|
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "has_published_stories", :default => false
  end

  add_index "languages", ["has_published_stories"], :name => "index_languages_on_has_published_stories"
  add_index "languages", ["locale"], :name => "index_languages_on_locale"
  add_index "languages", ["name"], :name => "index_languages_on_name"

  create_table "media", :force => true do |t|
    t.integer  "section_id"
    t.integer  "media_type"
    t.string   "old_title"
    t.string   "old_caption",       :limit => 180
    t.integer  "old_caption_align"
    t.string   "old_source"
    t.string   "audio_path"
    t.string   "video_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "video_loop",                       :default => true
    t.integer  "old_infobox_type",                 :default => 0
  end

  add_index "media", ["section_id", "position"], :name => "index_media_on_section_id_and_position"
  add_index "media", ["section_id"], :name => "index_media_on_section_id"

  create_table "medium_translations", :force => true do |t|
    t.integer  "medium_id"
    t.string   "locale",                     :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "title"
    t.string   "caption"
    t.integer  "caption_align"
    t.string   "source"
    t.integer  "infobox_type"
    t.integer  "media_type",    :limit => 1
  end

  add_index "medium_translations", ["locale"], :name => "index_medium_translations_on_locale"
  add_index "medium_translations", ["medium_id"], :name => "index_medium_translations_on_medium_id"

  create_table "news", :force => true do |t|
    t.boolean  "is_published", :default => false
    t.date     "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news", ["is_published", "published_at"], :name => "index_news_on_is_published_and_published_at"

  create_table "news_translations", :force => true do |t|
    t.integer  "news_id"
    t.string   "locale"
    t.string   "title"
    t.text     "content"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_translations", ["locale"], :name => "index_news_translations_on_locale"
  add_index "news_translations", ["news_id"], :name => "index_news_translations_on_news_id"
  add_index "news_translations", ["permalink"], :name => "index_news_translations_on_permalink"
  add_index "news_translations", ["title"], :name => "index_news_translations_on_title"

  create_table "notification_triggers", :force => true do |t|
    t.integer  "notification_type"
    t.integer  "identifier"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "processed",         :default => false
  end

  add_index "notification_triggers", ["notification_type"], :name => "index_notification_triggers_on_notification_type"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_type"
    t.integer  "identifier"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "notifications", ["notification_type", "identifier"], :name => "idx_notif_type"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "page_translations", :force => true do |t|
    t.integer  "page_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
    t.text     "content"
  end

  add_index "page_translations", ["locale"], :name => "index_page_translations_on_locale"
  add_index "page_translations", ["page_id"], :name => "index_page_translations_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"

  create_table "section_translations", :force => true do |t|
    t.integer  "section_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "section_translations", ["locale"], :name => "index_section_translations_on_locale"
  add_index "section_translations", ["section_id"], :name => "index_section_translations_on_section_id"

  create_table "sections", :force => true do |t|
    t.integer  "story_id"
    t.integer  "type_id"
    t.string   "old_title"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_marker", :default => true
  end

  add_index "sections", ["position"], :name => "index_sections_on_position"
  add_index "sections", ["story_id"], :name => "index_sections_on_story_id"

  create_table "slideshow_translations", :force => true do |t|
    t.integer  "slideshow_id"
    t.string   "locale",       :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "title"
    t.string   "caption"
    t.text     "description"
  end

  add_index "slideshow_translations", ["locale"], :name => "index_slideshow_translations_on_locale"
  add_index "slideshow_translations", ["slideshow_id"], :name => "index_slideshow_translations_on_slideshow_id"

  create_table "slideshows", :force => true do |t|
    t.integer  "section_id"
    t.string   "old_title"
    t.string   "old_caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slideshows", ["section_id"], :name => "index_slideshows_on_section_id"

  create_table "stories", :force => true do |t|
    t.string   "old_title"
    t.integer  "user_id"
    t.string   "old_author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "old_media_author"
    t.boolean  "old_published",         :default => false
    t.datetime "old_published_at"
    t.integer  "template_id",           :default => 1
    t.integer  "impressions_count",     :default => 0
    t.integer  "reviewer_key"
    t.string   "old_permalink"
    t.text     "old_about"
    t.boolean  "publish_home_page",     :default => true
    t.boolean  "staff_pick",            :default => false
    t.string   "story_locale"
    t.integer  "cached_votes_total",    :default => 0
    t.integer  "cached_votes_score",    :default => 0
    t.integer  "cached_votes_up",       :default => 0
    t.integer  "cached_votes_down",     :default => 0
    t.integer  "cached_weighted_score", :default => 0
    t.integer  "comments_count",        :default => 0
    t.string   "old_permalink_staging"
    t.integer  "story_type_id"
    t.boolean  "old_in_theme_slider"
  end

  add_index "stories", ["cached_votes_down"], :name => "index_stories_on_cached_votes_down"
  add_index "stories", ["cached_votes_score"], :name => "index_stories_on_cached_votes_score"
  add_index "stories", ["cached_votes_total"], :name => "index_stories_on_cached_votes_total"
  add_index "stories", ["cached_votes_up"], :name => "index_stories_on_cached_votes_up"
  add_index "stories", ["cached_weighted_score"], :name => "index_stories_on_cached_weighted_score"
  add_index "stories", ["comments_count"], :name => "index_stories_on_comments_count"
  add_index "stories", ["old_in_theme_slider"], :name => "index_stories_on_in_theme_slider"
  add_index "stories", ["old_permalink"], :name => "index_stories_on_permalink"
  add_index "stories", ["old_published"], :name => "index_stories_on_published"
  add_index "stories", ["old_published_at"], :name => "index_stories_on_published_at"
  add_index "stories", ["publish_home_page", "staff_pick"], :name => "index_stories_on_publish_home_page_and_staff_pick"
  add_index "stories", ["reviewer_key"], :name => "index_stories_on_reviewer_key"
  add_index "stories", ["story_locale"], :name => "index_stories_on_story_locale"
  add_index "stories", ["story_type_id"], :name => "index_stories_on_story_type_id"
  add_index "stories", ["template_id"], :name => "index_stories_on_template_id"
  add_index "stories", ["user_id"], :name => "index_stories_on_user_id"

  create_table "story_authors", :force => true do |t|
    t.integer  "story_id"
    t.integer  "author_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "story_authors", ["author_id"], :name => "index_story_authors_on_author_id"
  add_index "story_authors", ["story_id"], :name => "index_story_authors_on_story_id"

  create_table "story_categories", :force => true do |t|
    t.integer  "story_id"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "story_categories", ["category_id"], :name => "index_story_categories_on_category_id"
  add_index "story_categories", ["story_id"], :name => "index_story_categories_on_story_id"

  create_table "story_themes", :force => true do |t|
    t.integer  "story_id"
    t.integer  "theme_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "story_themes", ["story_id"], :name => "index_story_themes_on_story_id"
  add_index "story_themes", ["theme_id"], :name => "index_story_themes_on_theme_id"

  create_table "story_translation_progresses", :force => true do |t|
    t.integer  "story_id"
    t.string   "locale"
    t.integer  "items_completed", :default => 0
    t.boolean  "is_story_locale", :default => false
    t.boolean  "can_publish",     :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "story_translation_progresses", ["story_id", "can_publish"], :name => "index_story_translation_progresses_on_story_id_and_can_publish"
  add_index "story_translation_progresses", ["story_id", "locale"], :name => "index_story_translation_progresses_on_story_id_and_locale"

  create_table "story_translations", :force => true do |t|
    t.integer  "story_id"
    t.string   "locale",                                                       :null => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "shortened_url"
    t.string   "title"
    t.string   "permalink"
    t.string   "permalink_staging"
    t.string   "author"
    t.string   "media_author"
    t.text     "about"
    t.boolean  "published",                                 :default => false
    t.datetime "published_at"
    t.integer  "language_type",                :limit => 1, :default => 0
    t.integer  "translation_percent_complete", :limit => 1, :default => 0
    t.string   "translation_author"
    t.integer  "impressions_count",                         :default => 0
  end

  add_index "story_translations", ["language_type"], :name => "index_story_translations_on_language_type"
  add_index "story_translations", ["locale"], :name => "index_story_translations_on_locale"
  add_index "story_translations", ["permalink"], :name => "index_story_translations_on_permalink"
  add_index "story_translations", ["published"], :name => "index_story_translations_on_published"
  add_index "story_translations", ["published_at"], :name => "index_story_translations_on_published_at"
  add_index "story_translations", ["story_id"], :name => "index_story_translations_on_story_id"
  add_index "story_translations", ["title"], :name => "index_story_translations_on_title"

  create_table "story_type_translations", :force => true do |t|
    t.integer  "story_type_id"
    t.string   "locale",        :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "name"
    t.string   "permalink"
  end

  add_index "story_type_translations", ["locale"], :name => "index_story_type_translations_on_locale"
  add_index "story_type_translations", ["name"], :name => "index_story_type_translations_on_name"
  add_index "story_type_translations", ["permalink"], :name => "index_story_type_translations_on_permalink"
  add_index "story_type_translations", ["story_type_id"], :name => "index_story_type_translations_on_story_type_id"

  create_table "story_types", :force => true do |t|
    t.integer  "sort_order", :limit => 1, :default => 0
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "story_users", :force => true do |t|
    t.integer  "story_id"
    t.integer  "user_id"
    t.integer  "role",                :limit => 1, :default => 0
    t.string   "translation_locales"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "story_users", ["created_at"], :name => "index_story_users_on_created_at"
  add_index "story_users", ["role"], :name => "index_story_users_on_role"
  add_index "story_users", ["story_id"], :name => "index_stories_users_on_story_id"
  add_index "story_users", ["user_id"], :name => "index_stories_users_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "author"
    t.text     "params"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",      :default => true
  end

  add_index "templates", ["title"], :name => "index_templates_on_title"

  create_table "theme_features", :force => true do |t|
    t.integer  "theme_id"
    t.integer  "story_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "theme_features", ["position"], :name => "index_theme_features_on_position"
  add_index "theme_features", ["story_id", "position"], :name => "index_theme_features_on_story_id_and_position"
  add_index "theme_features", ["theme_id", "position"], :name => "index_theme_features_on_theme_id_and_position"

  create_table "theme_translations", :force => true do |t|
    t.integer  "theme_id"
    t.string   "locale",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "name"
    t.string   "edition"
    t.text     "description"
    t.string   "permalink"
  end

  add_index "theme_translations", ["locale"], :name => "index_theme_translations_on_locale"
  add_index "theme_translations", ["name"], :name => "index_theme_translations_on_name"
  add_index "theme_translations", ["permalink"], :name => "index_theme_translations_on_permalink"
  add_index "theme_translations", ["theme_id"], :name => "index_theme_translations_on_theme_id"

  create_table "themes", :force => true do |t|
    t.boolean  "is_published",   :default => false
    t.date     "published_at"
    t.boolean  "show_home_page", :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "themes", ["is_published", "published_at"], :name => "index_themes_on_is_published_and_published_at"
  add_index "themes", ["show_home_page"], :name => "index_themes_on_show_home_page"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.integer  "role",                   :default => 0,    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "avatar"
    t.text     "about"
    t.string   "default_story_locale",   :default => "en"
    t.string   "permalink"
    t.string   "old_avatar_file_name"
    t.string   "email_no_domain"
    t.boolean  "wants_notifications",    :default => true
    t.string   "notification_language",  :default => "en"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["email_no_domain"], :name => "index_users_on_email_no_domain"
  add_index "users", ["nickname"], :name => "index_users_on_nickname"
  add_index "users", ["notification_language", "wants_notifications"], :name => "index_users_on_notif_lang_and_wants_notif"
  add_index "users", ["permalink"], :name => "index_users_on_permalink"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], :name => "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], :name => "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

  create_table "youtube_translations", :force => true do |t|
    t.integer  "youtube_id"
    t.string   "locale",     :default => "en"
    t.string   "menu_lang",  :default => "en"
    t.string   "cc_lang",    :default => "en"
    t.text     "code"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "cc",         :default => true
    t.string   "title"
    t.string   "url"
  end

  add_index "youtube_translations", ["youtube_id", "locale"], :name => "index_youtube_langs_on_youtube_id_and_lang"

  create_table "youtubes", :force => true do |t|
    t.integer  "section_id"
    t.string   "old_title"
    t.string   "old_url"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "fullscreen", :default => false
    t.boolean  "loop",       :default => false
    t.boolean  "info",       :default => false
  end

  add_index "youtubes", ["section_id"], :name => "index_youtubes_on_section_id"

end
