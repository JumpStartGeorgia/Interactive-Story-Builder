START TRANSACTION;

######## 
# id of story to restore
set @story_id = 327;
######## 

######## 
# mysql does not work nicely with using variables for db names
# - so do a replace all if need to change db name
# live - story-builder
# restore - story-builder-restore
######## 

######## 
## all tables that need to be looked at:
#stories
#story_translations
#invitations
#stories_users
#story_categories
#asset (thumbnail - asset_type = 1 and item_id = story id)
#votes (votable_id = story id)
#taggings (taggable_id = story id)
#impressions (impressionable_id = story id)
#sections
#  contents
#  embed_media
#  asset (audio - asset_type = 2 and item_id = section_id)
#  slideshows
#    assets (asset_type = 6 and item_id = slide show id)
#  media
#    assets (asset_type = 4 or 5 and item_id = media id)
######## 



# story record
insert ignore into `story-builder`.stories
select * from `story-builder-restore`.stories where id = @story_id;

# translation record
insert ignore into `story-builder`.story_translations
select * from `story-builder-restore`.story_translations where story_id = @story_id;

# invitations
insert ignore into `story-builder`.invitations
select * from `story-builder-restore`.invitations where story_id = @story_id;

# story users
insert ignore into `story-builder`.stories_users
select * from `story-builder-restore`.stories_users where story_id = @story_id;

# story categories
insert ignore into `story-builder`.story_categories
select * from `story-builder-restore`.story_categories where story_id = @story_id;

# thumbnail
insert ignore into `story-builder`.assets
select * from `story-builder-restore`.assets where asset_type = 1 and item_id = @story_id;

# votes
insert ignore into `story-builder`.votes
select * from `story-builder-restore`.votes where votable_id = @story_id;

# tags
insert ignore into `story-builder`.taggings
select * from `story-builder-restore`.taggings where taggable_id = @story_id;

# views/impressions
#insert into `story-builder`.impressions
#select * from `story-builder-restore`.impressions where impressionable_id = @story_id;

# sections
insert ignore into `story-builder`.sections
select * from `story-builder-restore`.sections where story_id = @story_id;

# section audio 
insert ignore into `story-builder`.assets
select * from `story-builder-restore`.assets where asset_type = 2 and item_id in (select id from `story-builder-restore`.sections where story_id = @story_id);

# content
insert ignore into `story-builder`.contents
select * from `story-builder-restore`.contents where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id);

# embed media
insert ignore into `story-builder`.embed_media
select * from `story-builder-restore`.embed_media where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id);

# slideshows
insert ignore into `story-builder`.slideshows
select * from `story-builder-restore`.slideshows where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id);

# slideshow assets
insert ignore into `story-builder`.assets
select * from `story-builder-restore`.assets where asset_type = 6 and item_id in (
  select id from `story-builder-restore`.slideshows where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id)
);

# media
insert ignore into `story-builder`.media
select * from `story-builder-restore`.media where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id);

# media assets
insert ignore into `story-builder`.assets
select * from `story-builder-restore`.assets where asset_type in (4,5) and item_id in (
  select id from `story-builder-restore`.media where section_id in (select id from `story-builder-restore`.sections where story_id = @story_id)
);


COMMIT;