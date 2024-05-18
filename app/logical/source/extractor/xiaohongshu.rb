# frozen_string_literal: true

# @see Source::URL::Xiaohongshu
# @see https://github.com/NanmiCoder/MediaCrawler/blob/main/media_platform/xhs/client.py
class Source::Extractor::Xiaohongshu < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      note["imageList"].to_a.pluck("urlDefault").map do |url|
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def profile_url
    "https://www.xiaohongshu.com/user/profile/#{user_id}" if user_id.present?
  end

  def display_name
    note.dig("user", "nickname")
  end

  def tags
    note["tagList"].to_a.pluck("name").map do |tag|
      [tag, "https://www.xiaohongshu.com/search_result/?keyword=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    note["title"]
  end

  def artist_commentary_desc
    note["desc"]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || note.dig("user", "userId")
  end

  memoize def note
    page_json.dig("note", "noteDetailMap", post_id, "note") || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize def page_json
    page&.at('script[text()*="__INITIAL_STATE__"]')&.text&.slice(/{.*}/)&.gsub("undefined", "null")&.parse_json || {}
  end
end
