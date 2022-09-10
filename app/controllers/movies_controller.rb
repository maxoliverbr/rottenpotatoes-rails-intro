class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.all_ratings
    @sort = nil
    @ratings_to_show = nil

    if params[:s] == "x"
      session.clear
      @ratings_to_show = Hash[ *@all_ratings.collect { |v| [ v, 1 ] }.flatten ]
    end

    p "-------------------------"
    if params[:sort].nil? and params[:ratings].nil? and 
        (session[:sort].nil? and session[:ratings].nil?)   
      p "zero"  
      @ratings_to_show = Hash[ *@all_ratings.collect { |v| [ v, 1 ] }.flatten ]
      session[:ratings] = @ratings_to_show
      redirect_to movies_path(:ratings => session[:ratings])
    end

    
    if params[:ratings].nil? and params[:commit] == "Refresh"
      #p "t2"
      @ratings_to_show = Hash[ *@all_ratings.collect { |v| [ v, 1 ] }.flatten ]
      session[:ratings] = @ratings_to_show
    elsif not params[:ratings].nil? and params[:commit] == "Refresh"
      #p "t2.1"
      @ratings_to_show = params[:ratings].transform_keys(&:upcase)
      session[:ratings] = @ratings_to_show
    elsif not session[:ratings].nil?
      #p "t2.2"
      @ratings_to_show = session[:ratings]        
    else
    end

    if not params[:sort].nil?
      #p "t3"
      @sort = params[:sort].upcase
      session[:sort] = @sort
    elsif not session[:sort].nil?
            #p "t3.3"
            @sort = session[:sort]
    else
    end
    
    if @sort.nil?
        p "s1"
        @movies = Movie.with_ratings(@ratings_to_show)
    else
        p "s2"
        @sort = params[:sort] || session[:sort]
        case @sort.upcase
        when 'TITLE'
          ordering,@movie_title_css = {:title => :asc}, 'hilite'
        when 'RELEASE_DATE'
          ordering,@release_date_css = {:release_date => :asc}, 'hilite'
        end
        @movies = Movie.with_ratings(@ratings_to_show).order(ordering)
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
