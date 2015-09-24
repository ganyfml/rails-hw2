class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def sort_byAttribute(database, sort_by)
    movie = database.all
    if sort_by.nil? == false and sort_by != 'none'
      movie = database.order(sort_by)
    end
    return movie
  end

  def get_parameter(raw_parameter, type, default_value)
    parameter = []
    need_redirect = false
    if  raw_parameter.nil?
      if session[type].nil?
        parameter = default_value
      else
        parameter = session[type]
      end
      need_redirect = true
    else
      if type == 'rating'
        parameter = raw_parameter.keys
      else
        parameter = raw_parameter
      end
      session[type] = parameter
    end
    return parameter, need_redirect
  end

  def index
    @all_ratings = Movie.uniq.pluck('rating') 
    rating_filter, rating_redirect = get_parameter(params[:ratings], 'rating', @all_ratings) 
    sort_by, sort_redirect = get_parameter(params[:sort], 'sort', 'none')
    if rating_redirect or sort_redirect
      flash.keep
      redirect_to movies_path(:sort => sort_by, :ratings => Hash[rating_filter.collect { |v| [v, 1] }])
    end
    movie_afterSort = Movie.select_byRating(rating_filter)

    @check_status = {}
    @all_ratings.each do |rating_index|
      @check_status[rating_index] = rating_filter.include? rating_index 
    end

    @styles = {}
    @styles[sort_by] = 'hilite' unless sort_by.nil?
    @movies = sort_byAttribute(movie_afterSort, sort_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end

    def edit
      @movie = Movie.find params[:id]
    end

    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(params[:movie])
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end

    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end

  end
