module Member::MypageHelper
  def render_mypage_navi(opts = {})
    @mypage_node = Member::Node::Mypage.site(@cur_site).first
    current_node = opts[:current_node]

    h = []
    h << %(<nav id="mypage-tabs">)
    @mypage_node.children.each do |c|
      current = (current_node.url == c.url) ? " current" : ""
      h << %(<a class="tab-#{c.basename}#{current}" href="#{c.url}">#{c.name}</a>)
    end
    h << %(</nav>)
    h.join
  end
end
