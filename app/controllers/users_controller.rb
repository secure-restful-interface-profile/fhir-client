class UsersController < ActionController::Base

	def index
    # raw_parameters = {
    #   :provider => "Foo",
    #   :uid => "Bar",
    #   :name => "FooBar"
    # }
    # parameters = ActionController::Parameters.new(raw_parameters)
    # user = User.create!(parameters.permit(:provider, :uid, :name))
    user = User.where(provider: "Foo", uid: "Bar").first
    byebug
    byebug
	end

end