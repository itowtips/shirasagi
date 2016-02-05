module Member::BlogPageHelper
  def render_blog_template(name, opts = {})
    case name.to_sym
    when :genres
      render_genres(opts[:node])# rescue nil
    when :thumb
      render_thumb(opts[:node])# rescue nil
    else
      nil
    end
  end

  def render_genres(node)
    h = []
    h << %(<div class="member-blog-pages genres">)
    h << %(<h2>記事ジャンル</h2>)
    h << %(<ul>)

    pages = node.pages.public
    node.genres.each do |genre|
      count = pages.in(genres: genre).count
      next unless count > 0
      h << %(<li><a href="#{node.url}?g=#{genre}">#{genre}(#{count})</a></li>)
    end

    h << %(</ul>)
    h << %(</div>)
    h.join
  end

  def render_thumb(node)
    h = []
    h << %(<article class="member-blog-pages thumb">)
    h << %(<img src="#{node.thumb_url}" class="thumb" />)
    h << %(<header><h2><a href="#{node.url}">#{node.name}</a></h2></header>)
    h << %(<div class="description">#{node.description}</div>)
    h << %(</article>)
    h.join
  end
end
