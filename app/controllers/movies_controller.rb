class MoviesController < ApplicationController
  def index
    if params[:query].present?
      # Simple WHERE
      @results = Movie.where(title: params[:query])

      # Make it case insensitive
      @results = Movie.where("title ILIKE ?", params[:query])

      # Make it check if the query is contained in the title (not match exactly)
      @results = Movie.where("title ILIKE ?", "%#{params[:query]}%")

      # Search through title and synopsis
      sql_query = "title ILIKE :query OR synopsis ILIKE :query"
      @results = Movie.where(sql_query, query: "%#{params[:query]}%")

      # Search through the director's table as well
      sql_query = " \
        movies.title ILIKE :query \
        OR movies.synopsis ILIKE :query \
        OR directors.first_name ILIKE :query \
        OR directors.last_name ILIKE :query \
      "
      @results = Movie.joins(:director).where(sql_query, query: "%#{params[:query]}%")

      # Add full-text search
      sql_query = " \
        movies.title @@ :query \
        OR movies.synopsis @@ :query \
        OR directors.first_name @@ :query \
        OR directors.last_name @@ :query \
      "
      @results = Movie.joins(:director).where(sql_query, query: "%#{params[:query]}%")

      # PgSearch
      @results = Movie.search_by_title_and_synopsis("superman batm")

      # Multisearch against multiple tables
      @results = PgSearch.multisearch(params[:query])

      # ElasticSearch
      @results = Movie.search(params[:query])
    else
      @results = Movie.all
    end
  end
end
