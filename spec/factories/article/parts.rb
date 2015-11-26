FactoryGirl.define do
  factory :article_part_page, class: Article::Part::Page, traits: [:cms_part] do
    transient do
      site nil
      node nil
    end

    cur_site { site ? site : cms_site }
    filename { node ? "#{node.filename}/#{name}.part.html" : "dir/#{unique_id}.part.html" }
    route "article/page"
  end
end
