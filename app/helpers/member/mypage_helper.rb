module Member::MypageHelper
  def render_mypage_navi(opts = {})
    @mypage_node = Member::Node::Mypage.site(@cur_site).first

    h = []
    h << %(<nav id="mypage-tabs">)
    @mypage_node.children.each do |c|
      h << %(<a class="#{c.basename}" href="#{c.url}">#{c.name}</a>)
    end
    h << %(</nav>)
    h.join
  end
end
