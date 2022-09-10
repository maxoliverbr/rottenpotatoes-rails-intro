class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.all_ratings

    if params[:commit] == 'Refresh' and params[:ratings].nil?
      #p "r1"
      @ratings_to_show = Hash[ *@all_ratings.collect { |v| [ v, 1 ] }.flatten ]
      session[:ratings] = @ratings_to_show
    end 
    
    if params[:ratings].nil? and params[:sort].nil? 
      #p "t1"
      if not session[:ratings].nil?
        #p "t2"
        @ratings_to_show = session[:ratings]
      else
        #p "t3"
        @ratings_to_show = Hash[ *@all_ratings.collect { |v| [ v, 1 ] }.flatten ]
        session[:ratings] = @ratings_to_show
      end
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    else
      #p "t4"
      if params[:ratings].nil?
        @ratings_to_show = session[:ratings]
      else
        @ratings_to_show = params[:ratings]   
      end
    end
    
    @sort = params[:sort] || session[:sort]
    case @sort
    when 'title'
      ordering,@movie_title_css = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@release_date_css = {:release_date => :asc}, 'hilite'
    end
    
    @movies = Movie.with_ratings(@ratings_to_show).order(ordering)
    
    session[:sort]    = @sort
    session[:ratings] = @ratings_to_show
    @rating = @ratings_to_show

    
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