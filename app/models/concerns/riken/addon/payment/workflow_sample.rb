module Riken::Addon::Payment::WorkflowSample
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :workflow_id, type: String
    field :status, type: String
    field :url, type: String
    field :update_time, type: String
    field :delegation_start_date, type: String
    field :delegation_end_date, type: String
    field :proxy_id, type: String
    field :proxy_name, type: String
    field :proxy_lab, type: String
    field :proxy_position, type: String
    field :authorizer_id, type: String
    field :authorizer_name, type: String
    field :authorizer_lab, type: String
    field :authorizer_position, type: String
    field :delegation_1, type: String
    field :delegation_2, type: String
    field :delegation_3, type: String
    field :note, type: String
    field :create_time, type: String
    field :create_id, type: String
    field :create_name, type: String
    field :create_lab, type: String
    field :create_position, type: String

    validates :workflow_id, presence: true, length: { maximum: 255 }, uniqueness: { scope: :site_id }
    validates :status, presence: true, length: { maximum: 255 }
    validates :url, presence: true, length: { maximum: 255 }
    validates :update_time, presence: true, length: { maximum: 255 }
    validates :delegation_start_date, presence: true, length: { maximum: 255 }
    validates :delegation_end_date, presence: true, length: { maximum: 255 }
    validates :proxy_id, presence: true, length: { maximum: 255 }
    validates :proxy_name, presence: true, length: { maximum: 255 }
    validates :proxy_lab, presence: true, length: { maximum: 255 }
    validates :proxy_position, presence: true, length: { maximum: 255 }
    validates :authorizer_id, presence: true, length: { maximum: 255 }
    validates :authorizer_name, presence: true, length: { maximum: 255 }
    validates :authorizer_lab, presence: true, length: { maximum: 255 }
    validates :authorizer_position, presence: true, length: { maximum: 255 }
    validates :delegation_1, presence: true, length: { maximum: 255 }
    validates :delegation_2, presence: true, length: { maximum: 255 }
    validates :delegation_3, presence: true, length: { maximum: 255 }
    validates :note, presence: true, length: { maximum: 255 }
    validates :create_time, presence: true, length: { maximum: 255 }
    validates :create_id, presence: true, length: { maximum: 255 }
    validates :create_name, presence: true, length: { maximum: 255 }
    validates :create_lab, presence: true, length: { maximum: 255 }
    validates :create_position, presence: true, length: { maximum: 255 }

    permit_params :workflow_id, :status, :url, :update_time
    permit_params :delegation_start_date, :delegation_end_date
    permit_params :proxy_id, :proxy_name, :proxy_lab, :proxy_position
    permit_params :authorizer_id, :authorizer_name, :authorizer_lab, :authorizer_position
    permit_params :delegation_1, :delegation_2, :delegation_3, :note
    permit_params :create_time, :create_id, :create_name, :create_lab, :create_lab, :create_position
  end

  def api_attributes
    %w(
      workflow_id
      status
      url
      update_time
      delegation_start_date
      delegation_end_date
      proxy_id
      proxy_name
      proxy_lab
      proxy_position
      authorizer_id
      authorizer_name
      authorizer_lab
      authorizer_position
      delegation_1
      delegation_2
      delegation_3
      note
      create_time
      create_id
      create_name
      create_lab
      create_position
    ).map { |k| [(k == "workflow_id" ? "id" : k), send(k)] }.to_h
   end
end
