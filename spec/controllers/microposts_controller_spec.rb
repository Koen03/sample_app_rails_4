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
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id)

			get :index, format: :json, user_id: user.id
			parse_body = JSON.parse(response.body)
			returned_micropost = parse_body.first

			expect(returned_micropost["id"]).to eq micropost.id
			expect(returned_micropost["content"]).to eq "Winter is coming"
			expect(returned_micropost["user_id"]).to eq user.id

		end

	end

	describe "POST JSON create" do

		it "Micropost created" do
			sign_in(user, no_capybara: true)
			post :create, micropost: {content: "Winter is coming"}

			expect(assigns(:micropost)).to be_persisted
			expect(assigns(:micropost).user_id).to eq user.id
			expect(response).to redirect_to(root_url)
			expect(flash.to_hash[:success]).to eq "Micropost created!"


		end

		it  "Micropost created fail" do
			sign_in(user, no_capybara: true)
			post :create, micropost: {content: "a" * 200}

			expect(assigns(:micropost)).to_not be_persisted
			expect(response).to render_template('static_pages/home')

		end

	end

	describe "POST JSON destroy" do

		it "should delete a micropost" do
			sign_in(user, no_capybara: true)
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id)

			delete :destroy, id: micropost.id

			expect(assigns(:micropost)).to_not be_persisted
			expect(response).to redirect_to(root_url)			

		end

		it "should not delete a micropost from another user" do
			sign_in(user, no_capybara: true)
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id + 1)

			delete :destroy, id: micropost.id

			expect(micropost).to be_persisted
			expect(response).to redirect_to(root_url)

		end

	end	

	describe "POST JSON update" do

		it "should update a micropost" do
			sign_in(user, no_capybara: true)
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id)

			patch :update, id: micropost.id, micropost: { :content => "Winter has come" }
			micropost.reload

			expect(micropost).to be_persisted
			expect(micropost["content"]).to eq "Winter has come"
			expect(flash.to_hash[:success]).to eq "Post updated"
			expect(response).to redirect_to(root_url)
			expect(micropost["user_id"]).to eq user.id

		end

		it "should not update a micropost from another user" do
			sign_in(user, no_capybara: true)
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id + 1)

			patch :update, id: micropost.id, micropost: { :content => "Winter has come" }
			micropost.reload

			expect(micropost["content"]).to eq "Winter is coming"
			expect(response).to redirect_to(root_url)

		end

		it "should not update a micropost with empty content" do
			sign_in(user, no_capybara: true)
			micropost = Micropost.create(content: "Winter is coming", user_id: user.id)

			patch :update, id: micropost.id, micropost: { :content => "" }
			micropost.reload

			expect(response).to render_template('edit')
			expect(micropost['content']).to eq("Winter is coming")
			
		end
	end

end