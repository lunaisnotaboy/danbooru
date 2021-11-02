require "test_helper"

module Sources
  class PlurkTest < ActiveSupport::TestCase
    context "The source for a Plurk picture" do
      setup do
        @post_url = "https://www.plurk.com/p/om6zv4"
        @adult_post_url = "https://www.plurk.com/p/omc64y"
        @image_url = "https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg"
        @profile_url = "https://www.plurk.com/redeyehare"
        @post1 = Sources::Strategies.find(@post_url)
        @post2 = Sources::Strategies.find(@image_url)
        @post3 = Sources::Strategies.find(@profile_url)
        @post4 = Sources::Strategies.find(@adult_post_url)
      end

      should "not raise errors" do
        assert_nothing_raised { @post1.to_h }
        assert_nothing_raised { @post2.to_h }
        assert_nothing_raised { @post3.to_h }
        assert_nothing_raised { @post4.to_h }
      end

      should "get the artist name" do
        assert_equal("紅眼兔", @post1.artist_name)
        assert_equal("redeyehare", @post1.tag_name)
        assert_equal("BOW99", @post4.tag_name)
      end

      should "get profile url" do
        assert_equal(@profile_url, @post1.profile_url)
      end

      should "get the image url" do
        assert_equal(@image_url, @post1.image_url)
        assert_equal(@image_url, @post2.image_url)
      end

      should "get the image urls for an adult post" do
        images = ["https://images.plurk.com/yfnumBJqqoQt50Em6xKwf.png",
                  "https://images.plurk.com/5NaqqO3Yi6bQW1wKXq1Dc2.png",
                  "https://images.plurk.com/3HzNcbMhCozHPk5YY8j9fI.png",
                  "https://images.plurk.com/2e0duwn8BpSW9MGuUvbrim.png",
                  "https://images.plurk.com/1OuiMDp82hYPEUn64CWFFB.png",
                  "https://images.plurk.com/3F3KzZOabeMYkgTeseEZ0r.png",
                  "https://images.plurk.com/7onKKTAIXkY4pASszrBys8.png",
                  "https://images.plurk.com/6aotmjLGbtMLiI3slN7ODv.png",
                  "https://images.plurk.com/6pzn7jE2nkj9EV7H25L0x1.png",
                  "https://images.plurk.com/yA8egjDuhy0eNG9yxRj1d.png",]
        assert_equal(images, @post4.image_urls)
      end

      should "download an image" do
        assert_downloaded(627_697, @post1.image_url)
        assert_downloaded(627_697, @post2.image_url)
        assert_downloaded(520_122, @post4.image_url)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "redeyehare", url_string: @profile_url)
        assert_equal([@artist], @post1.artists)
        @adult_artist = FactoryBot.create(:artist, name: "bow", url_string: "https://www.plurk.com/BOW99")
        assert_equal([@adult_artist], @post4.artists)
      end
    end
  end
end
