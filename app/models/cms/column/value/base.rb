class Cms::Column::Value::Base
  extend SS::Translation
  include SS::Document
  include SS::Liquidization

  LINK_CHECK_EXCLUSION_FIELDS = %w(_id created updated deleted text_index column_id name order class_name _type file_id).freeze

  class_attribute :_permit_values, instance_accessor: false
  self._permit_values = []

  attr_reader :in_wrap, :link_errors, :origin_id

  embedded_in :page, inverse_of: :column_values
  belongs_to :column, class_name: 'Cms::Column::Base'
  field :name, type: String
  field :order, type: Integer
  field :alignment, type: String

  after_initialize :copy_column_settings, if: ->{ new_record? }

  validate :validate_value

  attr_accessor :link_check_user
  validate :validate_link_check, on: :link

  liquidize do
    export :name
    export :alignment
    export as: :html do |context|
      render_html_for_liquid(context)
    end
    export as: :to_s do |context|
      render_html_for_liquid(context)
    end
    export as: :type do
      self.class.name
    end
  end

  def self.permit_values(*fields)
    self._permit_values += Array.wrap(fields)
  end

  def to_html(options = {})
    return "" if column.blank?

    html = _to_html(options)

    wrap_data = []
    wrap_css_classes = []

    if options[:preview]
      wrap_data += [
        [ "page-id", _parent.id ], [ "column-id", id ], [ "column-name", ::CGI.escapeHTML(name) ],
        [ "column-order", order ]
      ]
      wrap_css_classes << "ss-preview-column"
    end

    if column.form.sub_type_entry?
      wrap_css_classes << "ss-alignment"
      wrap_css_classes << "ss-alignment-#{alignment.presence || "flow"}"
    end

    if wrap_data.present? || wrap_css_classes.present?
      attrs = []

      if wrap_data.present?
        attrs += wrap_data.map { |k, v| "data-#{k}=\"#{v}\"" }
      end
      if wrap_css_classes.present?
        attrs << "class=\"#{wrap_css_classes.join(" ")}\""
      end

      wrap = "<div #{attrs.join(" ")}>"
      wrap += html if html
      wrap += "</div>"

      html = wrap
    end

    html || ""
  end

  def all_file_ids
    # it should be overrided by subclass to provide all attached file ids.
    []
  end

  def clone_to(to_item)
    attrs = self.attributes.to_h.except('_id').slice(*self.class.fields.keys.map(&:to_s))
    ret = to_item.column_values.build(attrs)
    ret.instance_variable_set(:@new_clone, true)
    ret.instance_variable_set(:@origin_id, self.id)
    ret.created = ret.updated = Time.zone.now
    ret
  end

  def generate_public_files
  end

  def remove_public_files
  end

  def in_wrap=(value)
    self.attributes = @in_wrap = ActionController::Parameters.new(Hash(value)).permit(self.class._permit_values)
  end

  def import_csv(values)
    values.map do |name, value|
      case name
      when self.class.t(:alignment)
        self.alignment = value.present? ? I18n.t("cms.options.alignment").invert[value] : nil
      when self.class.t(:value)
        self.value = value
      end
    end
  end

  private

  def render_html_for_liquid(context)
    return to_default_html if @liquid_context

    @liquid_context = context
    begin
      to_html(preview: context.registers[:preview])
    ensure
      @liquid_context = nil
    end
  end

  def _to_html(options = {})
    layout = column.layout
    if layout.blank?
      return to_default_html
    end

    render_opts = { "value" => self }

    template = Liquid::Template.parse(layout)
    template.render(render_opts).html_safe
  end

  def validate_value
    return if column.blank?

    if column.required? && value.blank?
      self.errors.add(:value, :blank)
    end
  end

  def copy_column_settings
    if column.present?
      self.name ||= column.name
      self.order ||= column.order
    end
  end

  def to_default_html
    ApplicationController.helpers.sanitize(self.value)
  end

  def validate_link_check
    @link_errors = {}
    @root_url = column.form.site.full_root_url
    @fs_url = ::File.join(@root_url, "/fs/")
    @head_request_timeout = SS.config.cms.check_links["head_request_timeout"] rescue 5
    check = {}

    fields.each_key do |key|
      next if LINK_CHECK_EXCLUSION_FIELDS.include?(key)
      val = send(key)
      next unless val.is_a?(String)
      next if val.blank?
      find_url(val).each do |url|
        next if url[0] == '#'

        if url[0] == "/"
          url = ::File.join(@root_url, url)
        end

        next if check.key?(url)
        check[url] = true

        @link_errors[url] = check_url(url)
      end
    end
  end

  def find_url(val)
    val.scan(%r!<a.*?href="(.+?)">.+?</a>!).flatten | URI.extract(val, %w(http https))
  end

  def check_url(url)
    progress_data_size = nil

    url = normalize_url(url)
    proxy = ( url =~ /^https/ ) ? ENV['HTTPS_PROXY'] : ENV['HTTP_PROXY']
    http_basic_authentication = SS::MessageEncryptor.http_basic_authentication

    redirection = 0
    max_redirection = SS.config.cms.check_links["max_redirection"].to_i

    begin
      opts = {
        proxy: proxy,
        redirect: false,
        http_basic_authentication: http_basic_authentication,
        progress_proc: ->(size) do
          progress_data_size = size
          raise "200"
       end
      }

      Timeout.timeout(@head_request_timeout) do
        ::OpenURI.open_uri(url, opts) { |_f| }
      end

      return {
        code: 200,
        redirection: redirection
      }
    rescue OpenURI::HTTPRedirect => e
      if redirection >= max_redirection
        return {
          code: 0,
          message: I18n.t("errors.messages.link_check_failed_redirection"),
          redirection: redirection
        }
      else
        redirection += 1
        url = e.uri
        retry
      end
    rescue Addressable::URI::InvalidURIError
      return {
        code: 0,
        message: I18n.t("errors.messages.link_check_failed_invalid_link"),
        redirection: redirection
      }
    rescue OpenSSL::SSL::SSLError => e
      return {
        code: 0,
        message: I18n.t("errors.messages.link_check_failed_certificate_verify_failed"),
        redirection: redirection
      }
    rescue Timeout::Error
      return {
        code: 0,
        message: I18n.t("errors.messages.link_check_failed_timeout"),
        redirection: redirection
      }
    rescue => e
      if progress_data_size
        code = 200
        message = nil
      else
        code = 0
        if e.to_s == "401 Unauthorized"
          message = I18n.t("errors.messages.link_check_failed_unauthorized")
        else
          message = I18n.t("errors.messages.link_check_failed_not_found")
        end
      end

      return {
        code: code,
        message: message,
        redirection: redirection
      }
    end
  end

  def normalize_url(url)
    uri = ::Addressable::URI.parse(url)
    url = uri.normalize.to_s

    if @link_check_user && @fs_url && url.start_with?(@fs_url)
      token = SS::AccessToken.new(cur_user: @link_check_user)
      token.create_token
      if token.save
        url += uri.query.present? ? "&" : "?"
        url += "access_token=#{token.token}"
      end
    end

    url
  end
end
