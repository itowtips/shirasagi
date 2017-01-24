# module JobDb::Addon::Member::Target
#   extend ActiveSupport::Concern
#   extend SS::Addon
#
#   included do
#     field :target_class, type: String
#     permit_params :target_class
#   end
#
#   def target_class_options
#     %w(JobNavi::Member Emigration::Member BankSys::JobSeeker BankSys::CompanyMember).map do |v|
#       [ v.constantize.model_name.human, v ]
#     end
#   end
# end
