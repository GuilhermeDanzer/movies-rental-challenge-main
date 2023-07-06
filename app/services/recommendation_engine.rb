class RecommendationEngine
  def initialize(favorite_movies)
    @favorite_movies = favorite_movies
  end

  def recommendations
    movie_titles = extract_movie_titles(@favorite_movies)
    genres = fetch_movie_genres(movie_titles)
    common_genres = determine_common_genres(genres)
    retrieve_top_rated_movies(common_genres)
  end

  private

  def extract_movie_titles(movies)
    movies.map(&:title)
  end

  def fetch_movie_genres(titles)
    Movie.where(title: titles).pluck(:genre)
  end

  def determine_common_genres(genres)
    genre_counts = genres.tally
    sorted_genres = genre_counts.sort_by { |_genre, count| -count }
    top_genres = sorted_genres.map(&:first).take(3)
    top_genres
  end

  def retrieve_top_rated_movies(genres)
    Movie.where(genre: genres).order(rating: :desc).limit(10)
  end
end
