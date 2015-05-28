class Carrier < BaseModel
  include Searchable

  belongs_to :company, foreign_key: :yhtio, primary_key: :yhtio

  validates :nimi, :koodi, presence: true
  validates :neutraali, inclusion: { in: [true, false] }
  validates :pakkauksen_sarman_minimimitta, numericality: true

  self.table_name = :rahdinkuljettajat
  self.primary_key = :tunnus
end
