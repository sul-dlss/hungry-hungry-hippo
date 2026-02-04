# Form for easy deposit of an article by DOI
class ArticleForm < ApplicationForm
  attribute :doi, :string
  validates :doi, presence: true

  attribute :collection_druid, :string
end
