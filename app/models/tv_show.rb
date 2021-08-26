class TvShow < ApplicationRecord
  include PgSearch::Model

  # mutlisearch with pg_search
  multisearchable against: [:title, :synopsis]
end
