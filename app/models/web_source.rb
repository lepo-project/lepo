# == Schema Information
#
# Table name: web_sources
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebSource < ApplicationRecord
  has_many :snippets, -> { where(source_type: 'web') }, foreign_key: 'source_id'
  validates_presence_of :url
  validates :url, format: URI.regexp(%w[http https])

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.scratch_url?(url)
    url.include? 'http://scratch.mit.edu/projects/'
  end

  def self.pdf_url?(url)
    url[-4, 4].casecmp('.pdf').zero?
  end

  def self.scratch_id(url)
    return Regexp.last_match(1) if url[/projects\/([^\?]*)/]
  end

  def self.ted_url?(url)
    url.include? '://www.ted.com/talks/'
  end

  def self.ted_id(url)
    return Regexp.last_match(1) if url[/talks\/([^\?]*[^\?])/]
  end

  def self.youtube_url?(url)
    (url.include? '://www.youtube.com/watch') || (url.include? '://www.youtu.be/')
  end

  def self.youtube_id(url)
    if url[/youtu\.be\/([^\?]*)/]
      Regexp.last_match(1)
    else
      url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      Regexp.last_match(5)
    end
  end
end
