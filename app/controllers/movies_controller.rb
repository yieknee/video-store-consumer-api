class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    data = Movie.all
    render status: :ok, json: data
  end

  def search_input
  end

  def search
    @movie = Movie.find_by(title: params[:title])
    if !@movie
      @data = MovieWrapper.search(params[:title])

    else
      render(
        status: :ok,
        json: @movie.as_json(
          only: [:title, :overview, :release_date, :inventory],
          methods: [:available_inventory]
          )
      )
    end
  end

  # TODO: create a new movie instance in our rental library 
  def create
    @movie = Movie.new(
      title: params["title"],
      overview: params["overview"],
      release_date: params["release_date"],
      image_url: self.image_url(params["poster_path"]),
      external_id: params["id"],
      inventory: 10
    )
    
    if @movie.save
      render(
        status: :ok,
        json: @movie.as_json(
          only: [:title, :overview, :release_date, :inventory],
          methods: [:available_inventory]
          )
      )
    else
      render status: :bad_request, json: { errors: { title: ["Can't successfully create the movie with title #{params["title"]}"] } }
    end
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
