class UsersController < ApplicationController
  before_filter :require_user
  before_filter :decode_user_type, :except => ["archive", "impersonate"]
    
  append_before_filter :authorized?
  include SortHelper

  # Show 'active' users
  def index
    sort_init 'last_name'
    sort_update
    params[:sort_clause] = sort_clause
    @users = @user_type.active.search(params)
  end

  # Show 'archived' users
  def archived
    sort_init 'last_name'
    sort_update
    params[:sort_clause] = sort_clause
    @users = @user_type.archived.search(params)
    render :index
  end

  # Show the group of users
  def show
    sort_init 'last_name'
    sort_update
    params[:sort_clause] = sort_clause
    @users = @user_type.active.search(params)
    
		render :index
  end

  def new
    @user = @user_type.new
    render :action => 'edit'
  end


  def edit
    @user = User.find(params[:id])
  end


  def create
    @user = @user_type.new(params[:user])

    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to @user
    else
      render :action => :new
    end
    
  end


  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to @user
    else
      render :action => :edit
    end
  end


  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_url
  end

  
  def impersonate
    @user = User.find(params[:id])

    if UserSession.create(@user)
      flash[:warning] = "You are now impersonating '#{@user.full_name}'."
      redirect_to root_url
    else
      flash[:error] = "Impersonation failed."
      render :action => :show
    end
  end

  # Archive users
  def archive
    # The list of users is sent to this method using the "on" value.  Therefor we grab all the
    # elements in the params array that has a value of "on" and process them.
    params.reject{|k,v| v !="on" }.keys.each do |id|
      User.find(id).toggle_archive
    end

    redirect_to users_url
  end

  private

  # Decode the URL to figure out what type of user we are working with
  def decode_user_type
    @user_type = params[:id].nil? ? User : params[:id].camelcase.singularize.constantize
  end
end
