class CreateAbilities < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.string :key
      t.string :description

      t.timestamps
    end
    create_table :position_abilities do |t|
      t.belongs_to :position
      t.belongs_to :ability

      t.timestamps
    end
    add_index :position_abilities, :position_id
    add_index :position_abilities, :ability_id
    add_foreign_key :position_abilities, :abilities
    add_foreign_key :position_abilities, :positions
    Ability.create key: 'communicates', description: "Can see the names of submitters and communicate with them, can publish a magazine once it has stopped accepting submissions."
    Ability.create key: 'scores',       description: "Can enter (and see) scores for all submissions, can publish a magazine once it has stopped accepting submissions."
    Ability.create key: 'orchestrates', description: "Can schedule meetings, organize submissions to be reviewed at them, and record attendance for them."
    Ability.create key: 'views',        description: "Can view meetings and attendees."
    Ability.create key: 'disappears',   description: "This is a temporary position that will disappear once the magazine is published."
  end
end
