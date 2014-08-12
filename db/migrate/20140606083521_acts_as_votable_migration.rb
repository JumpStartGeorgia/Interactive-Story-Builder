class ActsAsVotableMigration < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|

      t.references :votable, :polymorphic => true
      t.references :voter, :polymorphic => true

      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight

      t.timestamps
    end

    if ActiveRecord::VERSION::MAJOR < 4
      add_index :votes, [:votable_id, :votable_type]
      add_index :votes, [:voter_id, :voter_type]
    end

    add_index :votes, [:voter_id, :voter_type, :vote_scope]
    add_index :votes, [:votable_id, :votable_type, :vote_scope]

    # store votes in story table so can do quick sorts
    add_column :stories, :cached_votes_total, :integer, :default => 0
    add_column :stories, :cached_votes_score, :integer, :default => 0
    add_column :stories, :cached_votes_up, :integer, :default => 0
    add_column :stories, :cached_votes_down, :integer, :default => 0
    add_column :stories, :cached_weighted_score, :integer, :default => 0
    add_index  :stories, :cached_votes_total
    add_index  :stories, :cached_votes_score
    add_index  :stories, :cached_votes_up
    add_index  :stories, :cached_votes_down
    add_index  :stories, :cached_weighted_score

  end

  def self.down
    drop_table :votes
    remove_column :stories, :cached_votes_total
    remove_column :stories, :cached_votes_score
    remove_column :stories, :cached_votes_up
    remove_column :stories, :cached_votes_down
    remove_column :stories, :cached_weighted_score
  end

end
