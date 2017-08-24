class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy, :edit, :update], unless: :json_request?


  def index
    user = if params[:user_id]
      User.find(params[:user_id])
    else
      current_user
    end
    render json: user.microposts.to_json

  rescue ActiveRecord::RecordNotFound => e
    render json: {error: e.message}, status: 404
  end

  def create 
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  def edit
    @micropost = Micropost.find(params[:id])
    respond_to do |format|
      format.html 
      format.json {render json: @micropost.to_json}
    end
  end

  def update
    @micropost = Micropost.find(params[:id]) if json_request?

    if @micropost.update_attributes(micropost_params)
      flash[:success] = "Post updated"
      respond_to do |format|
        format.html { redirect_to root_url }
        format.json {render json: @micropost.to_json}
      end
    else
      render 'edit'
    end

  end


  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
