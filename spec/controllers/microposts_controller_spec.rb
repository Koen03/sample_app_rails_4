require 'spec_helper'

describe MicropostsController do 

	let(:user) { User.create(name: "Piet", email: "piet.zwart@hotmail.com", password: "Hallo123", password_confirmation: "Hallo123") }

	describe "GET JSON index" do

		it 'When no user is found' do
			get :index, format: :json, user_id: 674583457385

			expect(
				JSON.parse(response.body)["error"]
			).to eq "Couldn't find User with id=674583457385" 
			expect(
				response.status).to eq 404
		end

		it 'When user is found without micropost' do

			get :index, format: :json, user_id: user.id

			expect(
				JSON.parse(response.body)
				).to eq []
		end

		it 'When user is found with micropost' do
			micropost = Micropost.create(content: "Test", user_id: user.id)

			get :index, format: :json, user_id: user.id
			parse_body = JSON.parse(response.body)
			returned_micropost = parse_body.first

			expect(returned_micropost["id"]).to eq micropost.id
			expect(returned_micropost["content"]).to eq "Test"
			expect(returned_micropost["user_id"]).to eq user.id

		end

	end

	describe "POST JSON create" do

		it "Micropost created" do
			sign_in(user, no_capybara: true)
			post :create, micropost: {content: "Winter is coming"}

			microposts = Micropost.where(content: "Winter is coming")
			micropost = microposts.first

			expect(microposts).not_to be_empty
			expect(micropost.user_id).to eq user.id

		end

		# it "Micropost empty" do
		# 	sign_in(user)
		# 	post :create, micropost: {content: ""}

		# 	expect(page).to have_content("Content can't be blank")

		# end


	end	
end