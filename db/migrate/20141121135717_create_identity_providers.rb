class CreateIdentityProviders < ActiveRecord::Migration
  def change
    create_table :identity_providers do |t|
      t.string :name
      t.string :uri
      t.string :client_id
      t.string :registration_client_uri
      t.text :registration_access_token
      t.string :logo

      t.timestamps
    end
  end
end
