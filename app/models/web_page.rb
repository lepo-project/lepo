# == Schema Information
#
# Table name: web_pages
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebPage < ApplicationRecord
  has_many :bookmarks, -> { where(target_type: 'web') }, foreign_key: 'target_id'
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
    rightmost_slash = url.rindex('/')
    return false unless rightmost_slash
    rightmost_part = url.slice(rightmost_slash + 1, url.length - rightmost_slash - 1)
    !rightmost_part.match(/.+\.pdf/).nil?
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

  def deletable?
    (bookmarks.size + snippets.size).zero?
  end
end
