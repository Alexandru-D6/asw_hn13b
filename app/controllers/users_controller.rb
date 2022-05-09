class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    if !params[:id].nil?
      @user = User.find_by(name: params[:id])
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      @user = User.find(params[:id])
      if @user.update(user_params)
        format.html { redirect_to "/user?id="+@user.name, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  
  ###############
  ##           ##
  ##           ##
  ##    API    ##
  ##           ##
  ##           ##
  ###############
  
  def show_api
    if params[:name].nil?
      render json: {status: 400, error: "Bad Request", message: "Insuficient parameters, missing about"}, status: 400
      return
    else
      if !User.exists?(name: params[:name])
        render json: {status: 404, error: "Not Found", message: "User with name: " + params[:name] + " doesn't exist in our database"}, status: 404
        return
      end
      
      @user = User.find_by(name: params[:name])
      render json: {status: 200, user: @user.as_json.except("updated_at", "provider", "uid", "auth_token")},status: 200
    end
  end
  
  def edit_api
    if request.headers["x-api-key"].nil?
      render json: {status: 401, error: "Unauthorized", message: "API key not found"}, status: 401
      return
    else
      
      if params[:about].nil?
        render json: {status: 400, error: "Bad Request", message: "Insuficient parameters, missing about"}, status: 400
        return
      end
      
      if !User.exists?(auth_token: request.headers["x-api-key"])
        render json: {status: 404, error: "Not Found", message: "User with apiKey: " + request.headers["x-api-key"] + " doesn't exist in our database"}, status: 404
        return
      end
      
      user = User.find_by(auth_token: request.headers["x-api-key"])
      
      if user.update(about: params[:about])
        render json: {status: 203, message: "User with name: " + user.name.to_s + " was successfully edited.", user: user.as_json.except("updated_at", "provider", "uid", "auth_token")}, status: 203
      else
        render json: {status: 400, error: "Bad Request", message: user.errors.first.full_message}, status: 400
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if params[:id].nil?
        @user = User.find(params[:id])
      else
        @user = User.find_by(name: params[:name])
      end
      @user
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:about)
    end
end
