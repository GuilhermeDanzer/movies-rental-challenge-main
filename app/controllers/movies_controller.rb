class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    render json: @movies
  end

  def recommendations
    favorite_movies = User.find(params[:user_id]).favorites.includes(:users)
    @recommendations = RecommendationEngine.new(favorite_movies).recommendations
    render json: @recommendations
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_rented_movies
    @rented = User.find(params[:user_id]).rented.includes(:users)
    render json: @rented
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def rent
  user = User.find(params[:user_id])
  movie = Movie.find(params[:id])

  if movie.available_copies.positive?
    movie.with_lock do
      movie.available_copies -= 1
      movie.save!
    end
    rental = Rental.create(user: user, movie: movie)  
    render json: rental
  else
    render json: { error: 'No available copies for this movie' }, status: :unprocessable_entity
  end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User or Movie not found' }, status: :not_found
  end
end