require 'cgi'
class UsersController < ApplicationController

  def accept_tag
    @user = Facebook.find(params[:id])
    tag_facebook = TagsFcaebook.where(:tag_id => params[:tag_id], :facebook_id => @user.id).first
    tag_facebook.status = Status.validated
    tag_facebook.save    
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
    end
  end

  def decline_tag
    @user = User.find(params[:id])
    user_tag = TagsUser.where(:tag_id => params[:tag_id], :user_id => @user.id).first
    user_tag.status = Status.rejected
    user_tag.save
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
    end
  end

  def return_tag
    @user = User.find(params[:id])
    TagsUser.create(:tag_id => params[:tag_id], :user_id => params[:to_user_id])
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user           = User.find(params[:id])

    @pending_tags   = TagsUser.where(:user_id => params[:id], :status_id => Status.pending.id)#.collect{|tag_user| tag_user.tag}
    @validated_tags = TagsUser.where(:user_id => params[:id], :status_id => Status.validated.id)#.collect{|tag_user| tag_user.tag}
    @rejected_tags  = TagsUser.where(:user_id => params[:id], :status_id => Status.rejected.id)#.collect{|tag_user| tag_user.tag}

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
