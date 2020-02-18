class Searching
  def self.find word
    unless word.nil?
      Wikipedia.configure {
        domain "en.wikipedia.org"
        path   "w/api.php"
      }

      page = Wikipedia.find word
      page.summary + "\n" + page.fullurl
    end
  end
end
