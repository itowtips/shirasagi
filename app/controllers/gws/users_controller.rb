class Gws::UsersController < ApplicationController
  include Gws::BaseFilter
  include SS::CrudFilter

  model Gws::User

  def get_params
    #params.require(:item).permit(gws_role_ids: [])
    params.require(:item).permit(:ldap_dn, gws_role_ids: [])
    # NOTE Want to remove :ldap_dn
  end
end
