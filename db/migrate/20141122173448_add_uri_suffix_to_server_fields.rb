class AddUriSuffixToServerFields < ActiveRecord::Migration
  def change
  	rename_column	:organizations, :authorization_server, :authorization_server_uri
  	rename_column	:organizations, :resource_server, :resource_server_uri
  end
end
