class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    @all_ratings = Movie.all_ratings
 
    if params[:sort].nil? && params[:ratings].nil? &&
      (!session[:sort].nil? || !session[:ratings].nil?)
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end

    if not params[:ratings].nil?
      @ratings_to_show = params[:ratings]
      @selected_ratings = params[:ratings]
      session[:ratings_to_show] = @ratings_to_show
    elsif not session[:ratings_to_show].nil?
      @ratings_to_show = session[:ratings_to_show]
      @selected_ratings = session[:ratings_to_show]
    else
        @ratings_to_show = {"G"=>"1", "PG"=>"1", "PG-13"=>"1", "NC-17"=>"1", "R"=>"1"}
        @selected_ratings = @ratings_to_show
    end  
       
    if not params[:sort].nil?
      @sort = params[:sort]
      session[:sort] = @sort
    elsif not session[:sort].nil?
        @sort = session[:sort]
    else
      @sort = ""
    end

    if @sort == "title"
        @movie_title_css = "hilite bg-warning"
        @release_date_css = ""
    elsif @sort == "release_date" 
        @release_date_css = "hilite bg-warning"
        @movie_title_css = ""
    else
      @release_date_css = ""
      @movie_title_css = ""
    end
    
    
    if @selected_ratings == nil and @sort == nil
      @movies = Movie.all
    elsif @selected_ratings == nil
      @movies = Movie.all.order(@sort)
    elsif @sort == nil
      @movies = Movie.where(rating: @selected_ratings.keys)
    else
      @movies = Movie.where(rating: @selected_ratings.keys).order(@sort)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
